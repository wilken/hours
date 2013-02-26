require 'omniauth'
require 'omniauth-google-oauth2'
require 'data_mapper'
require 'sinatra'
require 'json'

#use Rack::Static, :urls => ["/css","/js"], :root => 'public'

use Rack::Session::Cookie, :secret => ENV['RACK_COOKIE_SECRET']||"dklfsd"

use OmniAuth::Builder do
	provider :google_oauth2, 
		ENV['GOOGLE_KEY']||'306002293440-u2j17c459stf9cq8g9obqjfeug14bso4.apps.googleusercontent.com', 
		ENV['GOOGLE_SECRET']||'lE8e0jLAsvRzoGQpOAeSFSSB', 
		{access_type: 'online', approval_prompt: ''}
end 

Dir[File.dirname(__FILE__) + '/config/**/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }
require './api'
run Hours::API.new
