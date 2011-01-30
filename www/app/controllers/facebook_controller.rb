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
    if params[:code]
      logger.debug "FB login seems successful"
      fb_oauth               = MiniFB.oauth_access_token(BeerQuest::FB_APP_ID, login_url, BeerQuest::FB_SECRET, params[:code])
      session[:access_token] = fb_oauth['access_token']
      session[:facebook_id]  = MiniFB.get(session[:access_token], 'me').id
      logger.debug "Storing session: fbid=#{session[:facebook_id]} access_token=#{session[:access_token]}"
      redirect_to BeerQuest::FB_APP_URL
    else
      logger.error "FB login seems error => bust IFrame and start again"
      bust_iframe MiniFB.oauth_url(BeerQuest::FB_APP_ID, login_url, :scope => "")
    end
  end

  def session_logout
    reset_session
    logger.debug "Session destroyed"
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
      @me.first_name     = facebook_account[:first_name]
      @me.full_name      = facebook_account[:name]
      @me.gender         = facebook_account[:gender]
      #@@me.email = me[:email] à demander avec les droits supplémentaires
      @me.locale         = facebook_account[:locale] # ex: fr_FR
      @me.timezone       = facebook_account[:timezone] # 9
      @me.login_count    += 1
      @me.last_login     = DateTime.now
      @me.save

      # Friends
      my_current_friends = @me.friendships.inject({}) do |friends, f|
        friends[f.friend_id] = true
        friends
      end
      nonplaying_friends = {}
      logger.debug "My current friends were #{my_current_friends.inspect}"

      logger.debug "Asking FB for info about updated friend list"
      fb_friends = MiniFB.get(session[:access_token], "me", :type => "friends")
      logger.debug "Result: #{fb_friends.inspect}"
#      @me.friends = fb_friends[:data].inject({}) do |friends, f|
#        friends[f[:id].to_i] = f[:name]
#        friends
#      end
      fb_friends_ids = fb_friends[:data].map { |f| f[:id].to_i }
      logger.debug "Friends fbids are #{fb_friends_ids.inspect}"
      fb_friends_accounts = Account.all(:facebook_id => fb_friends_ids).inject({}) do |accounts, acc|
        accounts[acc.facebook_id] = acc.id
        accounts
      end
      logger.debug "Accounts already existing are: #{fb_friends_accounts.inspect}"
      fb_friends[:data].each do |f|
        logger.debug "== friend: #{f.inspect}"
        fid = f[:id].to_i

        # Check the account exists
        id  = fb_friends_accounts[fid]
        if id
          logger.debug "Account fbid=#{fid} already present in DB as id=#{id}: do nothing"
          if my_current_friends[id]
            my_current_friends.delete(id)
          else
            @me.friendships.create(:friend_id => id)
          end
          logger.debug "Updated friends-to-delete are: #{my_current_friends.inspect}"
        else
          logger.debug "Account fbid=#{fid} didn't exist in DB: store it into non-playing friends"
          nonplaying_friends[fid] = f[:name]
        end

      end
      logger.debug "== (end)"

      # Remove no-more friends
      logger.debug "Finally, removing no-more friends: #{my_current_friends.inspect}"
      my_current_friends.each_key do |id|
        logger.debug "Removing account #{id} from friends"
        friendship = @me.friendships.first(:friend_id => id)
        friendship.destroy
      end
      logger.debug "In the end, my playing friends are: #{@me.friends.inspect} and my non-playing friends are: #{nonplaying_friends}"
      @me.nonplaying_friends = nonplaying_friends

      # Account update: done!
      if @me.save
        logger.debug "Account #{@me.id} saved"
      end
      session[:account_id] = @me.id

      # Fix dashboard count value
      #      updated              = @me.update_fb_dashboard_count!
      #      logger.debug "Dashboard count updated to #{updated}"
    end

    # check admin status
    @admin = (@me.facebook_id == 1308311126 || @me.facebook_id == 674728432 || @me.facebook_id == 100001262927553 || @me.facebook_id == 100001227767696) # Matthieu / Joris / Cunégonde / Gérard
    if @admin
      logger.debug "Account #{@me.id} is ADMIN"
    end

    # (facultative) add default bar
    if @me.barships.empty?
      logger.debug "Account #{@me.id} has no barship => create default"
      @me.barships.create(:bar_id => Bar.default_bar.id)
    end

    # Invitations Facebook
    if params[:request_ids]
      pending_requests = MiniFB.get(session[:access_token], 'me', :type => 'apprequests')
      # <#Hashie::Mash data=[<#Hashie::Mash application=<#Hashie::Mash id="135204849839083" name="Beer Quest IV"> created_time="2011-01-30T12:16:37+0000" data="tracking test" from=<#Hashie::Mash id="100001227767696" name="Gérard Thaist"> id="1591009777659" message="Je te paries que tu ne pourras pas boire plus de bière que moi ! Viens te mesure |  moi sur Beer Quest IV. C'est un puzzle game fun et rapide |  jouer où l'objectif est de boire un max de bière !" to=<#Hashie::Mash id="1308311126" name="Matthieu Guillemot">>]>
      logger.debug "#{pending_requests.length} pending requests found:"
      pending_requests.data.each_with_index do |pending_request,i|
        # pending_request.data # tracking data
        logger.debug "Request ##{i}: #{pending_request.inspect}"
      end
      accepted_requests = params[:request_ids].split(',')
      logger.debug "#{accepted_requests.length} accepted requests received:"
      accepted_requests.each_with_index do |rid,i|
        logger.debug "Acceptation ##{i}: accepting request #{rid.to_i}"
        res = MiniFB.post(session[:access_token], rid.to_i, :method => :delete)
        logger.debug "Deletion result is #{res.inspect}"
        invite = @me.invites.first(:request_id => rid.to_i)
        if invite
          logger.debug "Found correponding BQ invite: #{invite.inspect}"
          invite.lang = "accepted" # TODO
          invite.save
          logger.debug "BQ invite saved: #{invite.saved?}"
        else
          logger.warn "Impossible to find corresponding BQ invite in the DB"
        end
      end
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
