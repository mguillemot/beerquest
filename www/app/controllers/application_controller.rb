class ApplicationController < ActionController::Base
	protect_from_forgery
	layout 'application'

	before_filter :facebook_auth

	protected

	def facebook_auth
		# params reçus de l'iframe englobante
		#		{"fb_sig_app_id"=>"135204849839083",
# "fb_sig_iframe_key"=>"1f0e3dad99908345f7439f8ffabdffc4",
# "fb_sig_locale"=>"fr_FR",
# "fb_sig_in_iframe"=>"1",
# "fb_sig"=>"723d160ea88fd2844acaf9411c8d1215",
# "fb_sig_in_new_facebook"=>"1",
# "fb_sig_added"=>"1",
# "fb_sig_country"=>"jp",
# "fb_sig_ext_perms"=>"email",
# "fb_sig_cookie_sig"=>"d2dab61b3349451f7afc6af99f26ea94",
# "fb_sig_session_key"=>"2.SUXi7gUjwY1qxq7l3X_s5w__.3600.1279551600-1308311126",
# "fb_sig_expires"=>"1279551600",
# "fb_sig_ss"=>"uTLU0M_nwtDfepl6j3w0Jg__",
# "fb_sig_api_key"=>"0afdbede62875307ab1210c209948428",
# "fb_sig_user"=>"1308311126",
# "fb_sig_profile_update_time"=>"1243460553",
# "fb_sig_time"=>"1279547333.9804"}

		@access_token = cookies[:access_token]
		if @access_token.present?
			begin
				MiniFB.get(@access_token, "me", :type => nil)
				@logged_in = true
			rescue MiniFB::FaceBookError
				logger.warn "You were not logged in, after all!"
				@access_token = nil
			end
		end

		if @logged_in
			logger.debug "Asking FB for info about user account"
			@me = MiniFB.get(@access_token, "me", :type => nil)
			logger.debug @me[:id]
			logger.debug @me[:email] # demandé avec les droits supplémentantes
			logger.debug @me[:first_name]
			logger.debug @me[:last_name]
			logger.debug @me[:name] # = first + last
			logger.debug @me[:gender]
			logger.debug @me[:locale] # ex: fr_FR
			logger.debug @me[:timezone] # 9
			logger.debug @me[:updated_time] # useless for us?

			logger.debug "Asking FB for info about user friends"
			@friends = MiniFB.get(@access_token, "me", :type => "friends")
			@friends[:data].each do |friend|
				logger.debug "#{friend[:id]} #{friend[:name]}"
			end

			logger.debug "Trying to post on my wall"
			begin
				@result = MiniFB.post(@access_token, "me", :type => "feed", :message => "Plup!")
				logger.debug @result
			rescue MiniFB::FaceBookError
				logger.error "Not authorized! (too bad...)"
			end
		end
	end
end
