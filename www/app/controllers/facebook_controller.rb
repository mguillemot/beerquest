class FacebookController < ApplicationController
	def authorize
		logger.debug "Recied account authorization"
		render :text => "authozied"
	end

	def delete
		logger.debug "Recied account deletion"
		render :text => "deleted"
	end

	def opensession
		if params[:code]
			access_token_hash = MiniFB.oauth_access_token(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "facebook/opensession", BeerQuest::FB_SECRET, params[:code])
			logger.debug "Received access token: #{access_token_hash}"
			@access_token = access_token_hash["access_token"]
			cookies[:access_token] = @access_token
			render :text => "session opened"
		else
			render :text => "failed with #{params[:error_reason]}"
		end
	end
end
