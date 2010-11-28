class FacebookController < ApplicationController

  WORLD_SCORE_TARGETS = [
          {:score => 100_000, :challenge => 'world_challenge.value.target100k'},
          {:score => 250_000, :challenge => 'world_challenge.value.target250k'}
  ]

  before_filter :user_details, :except => [:session_login, :session_logout]
  before_filter :set_locale
  before_filter :set_world_score

  def session_login
    reset_session
    session[:access_token] = MiniFB.oauth_access_token(BeerQuest::FB_APP_ID, login_url, BeerQuest::FB_SECRET, params[:code])['access_token']
    session[:user_id]      = MiniFB.get(session[:access_token], 'me').id
    redirect_to BeerQuest::FB_APP_URL
  end

  def session_logout
    session[:access_token] = nil
    session[:user_id]      = nil
    session[:account_id]   = nil
    redirect_to home_url
  end

  private

  def user_details
    # Facebook user
    if params[:signed_request]
      logger.debug "Decoding signed request #{params[:signed_request]}"
      data = facebook_signed_request?(params[:signed_request], BeerQuest::FB_SECRET)
      logger.debug " => result is #{data.inspect}"
      if data['user_id'] && data['oauth_token']
        logger.debug "Resetting session and setting facebook_id=#{data['user_id']} / access_token=#{data['oauth_token']} from signed request"
        session[:account_id]   = nil
        session[:facebook_id]  = data['user_id']
        session[:access_token] = data['oauth_token']
      else
        logger.warn "Invalid signed_request => ignoring it"
      end
    end
    if session[:access_token]
      logger.debug "Access token is #{session[:access_token]}"
    else
      logger.warn "No access token found: busting IFrame"
      bust_iframe MiniFB.oauth_url(BeerQuest::FB_APP_ID, login_url, :scope => "")
      return false
    end

    # App user
    if session[:account_id]
      logger.debug "Session ID is #{cookies['SID']}"
      logger.debug "Account found in session: #{session[:account_id]}"
      @me = Account.get(session[:account_id])
      if @me
        logger.debug "Account retrieved from DB: #{@me.full_name} fbid=#{@me.facebook_id}"
        if @me.facebook_id != session[:facebook_id]
          logger.warn "Discrepency between session fbid (#{session[:facebook_id]}) and session account fbid (#{@me.facebook_id}) => re-fetching account"
          session[:account_id] = nil
        end
      else
        logger.warn " => impossible to get corresponding account from DB: resetting session"
        session[:account_id] = nil
      end
    end
    unless session[:account_id]
      #flash.now[:notice]   = "Retrieved account info from FB: fbid=#{@facebook_id}"
      logger.debug "Trying to retrieve user #{session[:facebook_id]} from DB"
      @me = Account.first(:facebook_id => session[:facebook_id])
      unless @me
        logger.debug "Account didn't exist, create one"
        @me = Account.new(:facebook_id => session[:facebook_id])
      end
      logger.debug "Asking FB for info about user account #{session[:facebook_id]}"
      begin
        facebook_account = MiniFB.get(session[:access_token], "me")
        logger.debug "Received result is #{facebook_account.inspect}"
      rescue MiniFB::FaceBookError => ex
        logger.error "Facebook raised #{ex.inspect} => cancelling session & busting IFrame"
        reset_session
        bust_iframe MiniFB.oauth_url(BeerQuest::FB_APP_ID, login_url, :scope => "")
        return false
      end
      @me.full_name   = facebook_account[:name]
      @me.gender      = facebook_account[:gender]
      #@@me.email = me[:email] # demand� avec les droits suppl�mentantes
      @me.locale      = facebook_account[:locale] # ex: fr_FR
      @me.timezone    = facebook_account[:timezone] # 9
      @me.login_count += 1
      @me.last_login  = DateTime.now

      # Friends
      logger.debug "Asking FB for info about friends"
      fb_friends = MiniFB.get(session[:access_token], "me", :type => "friends")
      logger.debug "Result: #{fb_friends.inspect}"
      @me.friends = fb_friends[:data].inject({}) do |friends, f|
        friends[f[:id].to_i] = f[:name]
        friends
      end
#      fb_friends[:data].each do |f|
#        logger.debug "== friend: #{f.inspect}"
#        friend_account = Account.first(:facebook_id => f[:id])
#        if friend_account
#          logger.debug "Friend #{f[:id]} already present in DB: do nothing"
#        else
#          logger.debug "Friend #{f[:id]} didn't exist in DB: create it"
#          friend_account                    = @me.friends.new
#          friend_account.facebook_id        = f[:id]
#          friend_account.name               = f[:name]
#          friend_account.discovered_through = @me.id
#          friend_account.save
#        end
#      end
#      logger.debug "== (end)"

      # Remove no-more friends
#      current_friends.each do |f_id|
#        logger.debug "Friend #{f_id} is no more a friend: removing him"
#        @me.friends.delete @me.friends.find_by_id(f_id)
#      end

      logger.debug "Saving account #{@me.id}"
      @me.save
      session[:account_id] = @me.id

      # Fix dashboard count value
      updated              = @me.update_fb_dashboard_count!
      logger.debug "Dashboard count updated to #{updated}"
    end

    # check admin status
    @admin = (@me.facebook_id == 1308311126 || @me.facebook_id == 674728432) # Matthieu / Joris
    if @admin
      logger.debug "Account #{@me.id} is ADMIN"
    end

    # (facultative) add default bar
    if @me.barships.empty?
      logger.debug "Account #{@me.id} has no barship => create default"
      @me.barships.create(:bar_id => Bar.default_bar.id)
    end

    true
  end

  def set_locale
    if @me && @me.locale =~ /^fr/
      I18n.locale = 'fr'
      logger.debug "Set locale to #{I18n.locale}"
    else
      I18n.locale = 'en'
      logger.debug "Kept default locale of #{I18n.locale}"
    end
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
    sig  = str_to_hex(base64_url_decode(encoded_sig))
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

  def set_world_score
    @world_score          = World.total_beers
    @world_score_increase = World.increase_last_hour / 3600.0
    target                = WORLD_SCORE_TARGETS.find { |t| t[:score] > @world_score }
    if target
      @world_score_target = target[:score]
      @world_score_action = t(target[:challenge])
    else
      @world_score_target = 0
      @world_score_action = ''
    end
    true
  end

end
