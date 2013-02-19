require './api'
require 'omniauth'
require 'omniauth-google-oauth2'

use Rack::Static, :urls => ["/css","/js"], :root => 'public'

use Rack::Session::Cookie, :secret => ENV['RACK_COOKIE_SECRET']||"dklfsd"

use OmniAuth::Builder do
	provider :google_oauth2, 
		ENV['GOOGLE_KEY']||'306002293440-u2j17c459stf9cq8g9obqjfeug14bso4.apps.googleusercontent.com', 
		ENV['GOOGLE_SECRET']||'lE8e0jLAsvRzoGQpOAeSFSSB', 
		{access_type: 'online', approval_prompt: ''}
end  
run Hours::API.new
