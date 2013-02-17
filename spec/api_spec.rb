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
	      end

	      it 'returns error for 2013-01-0x1' do
	        get "/entries/2013-01-0x1"
	        last_response.status.should == 500
	      end
	    end
	end

end