require './api'

use Rack::Static, :urls => ["/css","/js"], :root => 'public', :index =>'index.html'

run Hours::API.new
