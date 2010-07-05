class HomeController < ApplicationController
	def index
		@oauth_url = MiniFB.oauth_url(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "facebook/opensession", :scope => "email")
	end

	def help
	end

	def privacy
	end

	def tos
	end
end
