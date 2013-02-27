module Hours
	module AuthHelpers
  		#Setup auth helpers
		def protected!
	    	unless authorized?
#		    		erb :landing
	    		redirect 'landing.html'
	    	end
	  	end

	  	def authorized?
	  		session['user'] != nil
	  	end
	end
end