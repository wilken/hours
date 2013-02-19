require 'data_mapper'
require 'sinatra'
require 'json'

set :public_folder, 'public'
set :sessions, true

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/entries_#{ENV['RACK_ENV']||'development'}.db")  
module Hours
	class Entry  
	  include DataMapper::Resource  
		property :id, Serial  
		property :company, String, :required => true  
		property :description, String, :required => true
		property :hours, Float, :required => true 
		property :date, Date, :required => true 
		property :user, String, :required => true 

		property :created_at, DateTime  
		property :updated_at, DateTime

	end  
	Entry.raise_on_save_failure = true

	DataMapper.finalize.auto_upgrade!

	class API < Sinatra::Base

		#Set default content type
		before do
		    content_type 'application/json'
  		end

  		#Setup auth helpers
		helpers do
			def protected!
		    	unless authorized?
		    		redirect '/landing.html'
		    	end
		  	end

		  	def authorized?
		  		session['user'] != nil
		  	end
		end

		get '/' do
			protected!
			content_type 'text/html'
			erb :index
		end

		get '/entries/:date' do
			protected!
			begin
	    		d = Date.parse(params[:date])
	    		{entries:Entry.all(date: d, user: session['user'])}.to_json
	    	rescue
	    		begin
		    		d = Date.parse("#{params[:date]}-01")
		    		{entries:Entry.all(:date.gte => d, :date.lt => d >> 1)}.to_json
		    	rescue Exception => e
					[500, {status:"error", description: e}.to_json]
		    	end
			end
		end

		post '/entries/:date' do
			protected!
			begin
				d = Date.parse(params[:date])
				Entry.transaction do

					#Fetch the entries array from request
					entries = JSON.parse(request.body.read)["entries"]

		    		#Delete old entries for date
		    		Entry.all(date: d).destroy!

		    		#Insert new entries for date
		    		entries.each do |entry|
			    		Entry.create(
			    			company: 		entry["company"],
			    			description: 	entry["description"],
			    			hours: 			entry["hours"],
			    			date: 			d,
			    			user: 			session['user']
			    		)
		    		end
			   		{status:"OK"}.to_json
			   	end
	    	rescue Exception => e
				[500, {status:"error", description: e}.to_json]
	    	end
		end

		get '/login' do
			content_type 'text/html'
    		<<-HTML
    		<ul>
     			<li><a href='/auth/google_oauth2'>Sign in with Google</a></li>
    		</ul>
    		HTML
  		end

		get '/auth/:provider/callback' do
			session['user'] = request.env['omniauth.auth'].info.email
			redirect '/'
		end
  
		get '/auth/failure' do
    		content_type 'text/plain'
    		request.env['omniauth.auth'].to_hash.inspect rescue "No Data"
		end
	end
end
