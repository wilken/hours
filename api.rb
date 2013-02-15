require 'data_mapper'
require 'sinatra'
require 'json'

set :public_folder, 'public'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/entries_#{ENV['RACK_ENV']||'development'}.db")  
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
		get '/entries/:date' do
			begin
	    		d = Date.parse(params[:date])
	    		{entries:Entry.all(date: d)}.to_json
	    	rescue
	    		d = Date.parse("#{params[:date]}-01")
	    		{entries:Entry.all(:date.gte => d, :date.lt => d >> 1)}.to_json
			end
		end

		post '/entries/:date' do
			d = Date.parse(params[:date])
			Entry.transaction do
	    		Entry.all(date: d).destroy!
	    		params[:entries].each do |entry|
	    			p entry
		    		Entry.create(
		    			company: 		entry[:company],
		    			description: 	entry[:description],
		    			hours: 			entry[:hours],
		    			date: 			d,
		    			user: 			"mw"
		    		)
	    		end
		   		{status:"OK"}.to_json
		   	end
		end
	end
end
