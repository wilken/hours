module Hours
	class AuthRoute < Sinatra::Base
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