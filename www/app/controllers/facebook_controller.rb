class FacebookController < ApplicationController
	before_filter :facebook_auth, :except => :opensession

	def index
		# TODO proposer mode invité en détectant params[:fb_sig_logged_out_facebook]=>"1" ou pas
	end

#	def authorize
#		logger.debug "Recived account authorization"
#		render :text => "authozied"
#	end
#
#	def delete
#		logger.debug "Received account deletion"
#		render :text => "deleted"
#	end

	def opensession
		if params[:code]
			access_token_hash = MiniFB.oauth_access_token(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "/opensession", BeerQuest::FB_SECRET, params[:code])
			logger.debug "Received access token #{access_token_hash}. Session opened."
			@access_token = access_token_hash["access_token"]
			cookies[:access_token] = @access_token
			redirect_to BeerQuest::FB_APP_URL
		else
			render :text => "failed with #{params[:error_reason]}"
		end
	end

#	def connect
#		@fb_info = MiniFB.parse_cookie_information(BeerQuest::FB_APP_ID, cookies)
#		logger.debug "Facebook CONNECT!!!!!!"
#		logger.debug @fb_info
#
#		if MiniFB.verify_cookie_signature(BeerQuest::FB_APP_ID, BeerQuest::FB_SECRET, cookies)
	# And here you would create the user if it doesn't already exist, then redirect them to wherever you want.
#			redirect_to BeerQuest::FB_APP_URL
#		else
	# The cookies may have been modified as the signature does not match
#			render :text => "BIG ERROR"
#		end
#	end

	protected

	def facebook_auth
		@oauth_url = MiniFB.oauth_url(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "/opensession", :scope => "email")

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

		unless @logged_in
			redirect_to @oauth_url
			return false
		end

		logger.debug "Asking FB for info about user account"
		@me = MiniFB.get(@access_token, "me", :type => nil)
		begin
			@account = Account.find_by_facebook_id(@me[:id])
		rescue ActiveRecord::RecordNotFound
			@account = Account.new
		end
		@account.email = @me[:email] # demandé avec les droits supplémentantes
		@account.first_name = @me[:first_name]
		@account.last_name = @me[:last_name]
		@account.gender = @me[:gender]
		@account.locale = @me[:locale] # ex: fr_FR
		@account.timezone = @me[:timezone] # 9
		@account.login_count += 1
		@account.last_login = DateTime.now
		@account.save!

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

		true
	end
end
