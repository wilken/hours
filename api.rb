module Hours
	class API < Sinatra::Base
		use Hours::AuthRoute
		use Hours::EntriesRoute

		#Set default content type
		before do
		    content_type 'application/json'
  		end

		get '/' do
			protected!
			content_type 'text/html'
			erb :index
		end
	end
end
