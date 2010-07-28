class FacebookController < ApplicationController
	def authorize
		logger.debug "Recied account authorization"
		render :text => "authozied"
	end

	def delete
		logger.debug "Received account deletion"
		render :text => "deleted"
	end

	def opensession
		if params[:code]
			access_token_hash = MiniFB.oauth_access_token(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "facebook/opensession", BeerQuest::FB_SECRET, params[:code])
			logger.debug "Received access token #{access_token_hash}. Session opened."
			@access_token = access_token_hash["access_token"]
			cookies[:access_token] = @access_token
			redirect_to BeerQuest::FB_APP_URL
		else
			render :text => "failed with #{params[:error_reason]}"
		end
	end

	def connect
		@fb_info = MiniFB.parse_cookie_information(BeerQuest::FB_APP_ID, cookies)
		logger.debug "Facebook CONNECT!!!!!!"
		logger.debug @fb_info

		if MiniFB.verify_cookie_signature(BeerQuest::FB_APP_ID, BeerQuest::FB_SECRET, cookies)
			# And here you would create the user if it doesn't already exist, then redirect them to wherever you want.
			redirect_to BeerQuest::FB_APP_URL
		else
			# The cookies may have been modified as the signature does not match
			render :text => "BIG ERROR"
		end
	end  
end
