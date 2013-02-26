module Hours
	class API < Sinatra::Base
		helpers Hours::Authorization

		set :root,'.'
		set :views, 'views'

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
