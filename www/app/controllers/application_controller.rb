class ApplicationController < ActionController::Base
	protect_from_forgery
	layout 'application'

	before_filter :facebook_auth

	protected

	def facebook_auth
		@access_token = cookies[:access_token]
		@logged_in = @access_token.present?

		if @logged_in
			@response_hash = MiniFB.get(@access_token, "me", :type => nil)
			# me/friends
			@response_hash[:id]
			@response_hash[:email] # demandé avec les droits supplémentantes
			@response_hash[:first_name]
			@response_hash[:last_name]
			@response_hash[:name] # = first + last
			@response_hash[:gender]
			@response_hash[:locale] # ex: fr_FR
			@response_hash[:timezone] # 9
			@response_hash[:updated_time] # useless for us?
		end
	end
end
