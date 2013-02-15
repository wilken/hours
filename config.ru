require './api'

use Rack::Static, :urls => ["/css","/js"], :root => 'public', :index =>'index.html'
use Rack::Auth::Basic do |username, password|
  [username, password] == ['admin', 'admin']
end
run Hours::API.new
