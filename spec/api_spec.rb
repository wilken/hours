require 'rack/test'
require './api'
describe Hours::API do
	include Rack::Test::Methods

	def app
		Hours::API
	end
	
	describe Hours::API do
	    describe 'GET /entries/2013-01-01' do
	      it 'returns entries for 2013-01-01' do
	        get "/entries/2013-01-01"
	        last_response.status.should == 200
	        JSON.parse(last_response.body)["entries"].should_not be_empty
	      end
	    end
	end

end