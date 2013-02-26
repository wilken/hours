module Hours
	class API < Sinatra::Base
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
	end
end