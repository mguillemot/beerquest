class HomeController < ApplicationController
	def index
		# Get your oauth url
		@oauth_url = MiniFB.oauth_url(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "sessions/create", :scope => MiniFB.scopes.join(","))

#		access_token_hash = MiniFB.oauth_access_token(FB_APP_ID, "http://www.yoursite.com/sessions/create", FB_SECRET, params[:code])
#		@access_token = access_token_hash["access_token"]
#		cookies[:access_token] = @access_token
	end

	def help
	end

	def privacy
	end

	def tos
	end
end
