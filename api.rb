require 'data_mapper'
require 'sinatra'
require 'json'

set :public_folder, 'public'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/entries_#{ENV['RACK_ENV']||'development'}.db")  
module Hours
	class Entry  
	  include DataMapper::Resource  
		property :id, Serial  
		property :company, String, :required => true  
		property :description, String, :required => true
		property :hours, Decimal, :required => true ,:precision => 10, :scale => 2
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
		      		response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
		     	 	throw(:halt, [401, {status:"error", description: "Not authorized"}.to_json])	
		    	end
		  	end

		  	def authorized?
		   		@auth ||=  Rack::Auth::Basic::Request.new(request.env)
		    	@auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
		  	end
		end


		get '/entries/:date' do
			protected!
			begin
	    		d = Date.parse(params[:date])
	    		{entries:Entry.all(date: d)}.to_json
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
			    			user: 			"mw"
			    		)
		    		end
			   		{status:"OK"}.to_json
			   	end
	    	rescue Exception => e
				[500, {status:"error", description: e}.to_json]
	    	end
		end
	end
end
