module Hours
	module Authorization
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