module Hours
	class EntriesRoute < Sinatra::Base
		helpers Hours::AuthHelpers

		get '/entries/:date' do
			protected!
			begin
				#If date is on the form YYYY-MM-DD
	    		d = Date.parse(params[:date])
	    		{entries:Entry.all(date: d, user: session['user'])}.to_json
	    	rescue
	    		begin
					#If date is on the form YYYY-MM, for use in summary queries
		    		d = Date.parse("#{params[:date]}-01")
		    		{entries:Entry.all(:date.gte => d, :date.lt => d >> 1, user: session['user'])}.to_json
		    	rescue Exception => e
		    		# If date is malformed
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