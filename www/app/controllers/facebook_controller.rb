class FacebookController < ApplicationController

  before_filter :user_details, :except => [:session_login, :session_logout]

  def session_login
    reset_session
    session[:access_token] = MiniFB.oauth_access_token(BeerQuest::FB_APP_ID, login_url, BeerQuest::FB_SECRET, params[:code])['access_token']
    session[:user_id] = MiniFB.get(session[:access_token], 'me').id
    #bust_iframe(BeerQuest::FB_APP_URL)
    # TODO tester et voir si �a convient
    redirect_to home_url
  end

  def session_logout
    session[:access_token] = nil
    session[:user_id] = nil
    session[:account_id] = nil
    redirect_to home_url
  end

  private

  def user_details
    # Facebook user
    if params[:signed_request]
      data = facebook_signed_request?(params[:signed_request], BeerQuest::FB_SECRET)
      if data[:user_id] && data[:oauth_token]
        session[:user_id] = data[:user_id]
        session[:access_token] = data[:oauth_token]
      end
    end
    @access_token = session[:access_token]
    @user_id = session[:user_id]
    if session[:access_token].nil?
      bust_iframe MiniFB.oauth_url(BeerQuest::FB_APP_ID, login_url, :scope => "")
      return false
    end

    # App user
    if session[:account_id]
      logger.debug "Account was stored in session: #{session[:account_id]}"
      @me = Account.get(session[:account_id])
    else
      flash.now[:notice] = "Retrieve account info from FB"
      logger.debug "Trying to retrieve user #{@user_id} from DB"
      @me = Account.first(:facebook_id => @user_id)
      unless @me
        logger.debug "Account didn't exist, create one"
        @me = Account.new(:facebook_id => @user_id)
      end
      logger.debug "Asking FB for info about user account #{@user_id}"
      facebook_account = MiniFB.get(@access_token, "me")
      @me.first_name = facebook_account[:first_name]
      @me.last_name = facebook_account[:last_name]
      @me.gender = facebook_account[:gender]
      #@@me.email = me[:email] # demand� avec les droits suppl�mentantes
      @me.locale = facebook_account[:locale] # ex: fr_FR
      @me.timezone = facebook_account[:timezone] # 9
      @me.profile_picture = "http://graph.facebook.com/#{@user_id}/picture"
      @me.login_count += 1
      @me.last_login = DateTime.now
      @me.save
      session[:account_id] = @me.id

      # Friends
#      logger.debug "Current friends (before updating):"
#      @me.friends.each do |f|
#        logger.debug "== fbid: #{f.facebook_id}"
#      end
#
#      current_friends = @me.friendships.map { |fs| fs.friend_id }
#      logger.debug "Asking FB for info about user friends"
#      fb_friends = MiniFB.get(@access_token, "me", :type => "friends")
#      fb_friends[:data].each do |f|
#        logger.debug "friend: #{f[:id]} #{f[:name]}"
#        friend_account = Account.find_by_facebook_id f[:id]
#        unless friend_account
#          logger.debug "Friend #{f[:id]} didn't exist in DB: create it"
#          friend_account = @me.friends.new
#          friend_account.facebook_id = f[:id]
#          friend_account.discovered_through = @me.id
#          if f[:name]
#            friend_name = f[:name].split(' ', 2)
#            friend_account.first_name = friend_name[0]
#            friend_account.last_name = friend_name[1]
#          end
#          friend_account.profile_picture = "http://graph.facebook.com/#{f[:id]}/picture"
#          friend_account.save!
#        else
#          unless current_friends.reject! f[:id]
#            logger.debug "Friend #{f[:id]} was already existing but not registered as friend yet"
#            @me.friends << friend_account
#          else
#            logger.debug "Friend #{f[:id]} was already existing and registered as friend"
#          end
#        end
#      end
      # Remove no-more friends
#      current_friends.each do |f_id|
#        logger.debug "Friend #{f_id} is no more a friend: removing him"
#        @me.friends.delete @me.friends.find_by_id(f_id)
#      end
    end

    # (facultative) add default bar
    @me.barships.create(:bar_id => Bar.default_bar.id) if @me.barships.empty?

    true
  end

  def bust_iframe(url)
    render :text => "<html><body><script>parent.location.href='#{url}';</script></body></html>"
    true
  end

  def facebook_signed_request? (signed_request, secret)
    require 'base64'
    require 'openssl'

    def base64_url_decode(str)
      encoded_str = str.gsub('-', '+').gsub('_', '/')
      encoded_str += '=' while !(encoded_str.size % 4).zero?
      Base64.decode64(encoded_str)
    end

    def str_to_hex(s)
      (0..(s.size-1)).to_a.map do |i|
        number = s[i].to_s(16)
        (s[i] < 16) ? ('0' + number) : number
      end.join
    end

    #decode data
    encoded_sig, payload = signed_request.split('.')
    sig = str_to_hex(base64_url_decode(encoded_sig))
    data = ActiveSupport::JSON.decode base64_url_decode(payload)

    if data['algorithm'].to_s.upcase != 'HMAC-SHA256'
      logger.error 'Unknown algorithm. Expected HMAC-SHA256'
      return false
    end

    #check sig
    expected_sig = OpenSSL::HMAC.hexdigest('sha256', secret, payload)
    if expected_sig != sig
      logger.error 'Bad Signed JSON signature!'
      return false
    end

    data
  end

end
