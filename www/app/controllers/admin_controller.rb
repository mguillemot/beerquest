class AdminController < ApplicationController

  before_filter :admin_required
  before_filter :check_restrictions

  # To log as another user (to see what he sees...)
  def log_as
    account = Account.get(params[:id])
    unless account
      throw "unable to find account id #{params[:id]}"
    end
    account.last_login  = DateTime.now
    account.login_count += 1
    account.save

    session[:account_id]   = params[:id]
    session[:facebook_id]  =account.facebook_id
    session[:access_token] = "none"

    redirect_to home_url
  end

  # To check the validity of a replay
  def check_game
    @replay = Replay.get(params[:id])
    @game   = Game::Game.new
    @game.start(@replay.seed)
#    @game.board.decode "fvvvtvvv" +
#                               "fvvvrttv" +
#                               "vfvbbrrv" +
#                               "vvvvrbbv" +
#                               "vvvvbrrv" +
#                               "vvvvrbbv" +
#                               "vvvwbrrv" +
#                               "vwwvwbbv"
    decoded_replay = JSON.parse(@replay.replay, :symbolize_names => true)
    @steps         = []
    @steps.push("Initial status with seed=#{@replay.seed}")
    @steps.push(@game.dup)
    # TODO vérifier que les opérations (ex: swap) sont autorisées
    decoded_replay.each do |r|
      case r[:type]
        when "swap"
          src = [r[:sx], r[:sy]]
          dst = [r[:dx], r[:dy]]
          @steps.push("Swapping #{src.inspect} and #{dst.inspect}")
          @game.swap_cells(src, dst)
          @steps.push(@game.dup)
        when "capacity"
          @steps.push("Using capacity \"#{r[:capacity]}\" targetting \"#{r[:target]}\"")
          unless @game.capacities.include? r[:capacity]
            @steps.push("ERROR: No such capacity is usable")
          else
            @game.execute_capacity(r[:capacity], r[:target])
          end
        when "piss"
          before_piss = @game.piss
          @game.do_piss
          @steps.push("Pissed: #{before_piss} => #{@game.piss}")
        when "reset"
          @steps.push("A reset happened here")
        when "status"
          if r[:board] == @game.board.encoded_state
            @steps.push("Checked status: expected #{r[:board]} vs actual #{@game.board.encoded_state}")
          else
            @steps.push("Failed status check: expected #{r[:board]} vs actual #{@game.board.encoded_state}")
          end
        else
          @steps.push("Ignoring \"#{r[:type]}\"")
      end
    end

    render :layout => false
  end

  def test_accounts
    cred      = MiniFB.authenticate_as_app(BeerQuest::FB_APP_ID, BeerQuest::FB_SECRET)
    call      = MiniFB.get(cred['access_token'], BeerQuest::FB_APP_ID, :type => 'accounts')
    @accounts = call['data']
    logger.debug "Raw data: #{@accounts.inspect}"
    @accounts.each do |account|
      bq = Account.first(:facebook_id => account['id'])
      if bq
        account['name'] = bq.full_name
      end

      db_count = MiniFB.call(BeerQuest::FB_API_KEY, BeerQuest::FB_SECRET, 'dashboard.getCount', 'uid' => account['id'], 'quickreturn' => true)
      if db_count
        account['dashboard_count'] = db_count.to_i
      end
    end
    logger.debug "Augmented data: #{@accounts.inspect}"

    # Set all accounts as mutual friends
    for i in 0..@accounts.size
      for j in (i+1)..@accounts.size
        f1 = @accounts[i]
        f2 = @accounts[j]
        logger.debug "Friends: i=#{i} j=#{j} f1=#{f1.inspect} f2=#{f2.inspect}"
        MiniFB.post(f1['access_token'], f1['id'], :type => 'friends/' + f2['id']) rescue logger.debug("request ko")
        MiniFB.post(f2['access_token'], f2['id'], :type => 'friends/' + f1['id']) rescue logger.debug("accept ko")
      end
    end
    logger.debug "Friends all done!"
  end

  def new_test_account
    cred = MiniFB.authenticate_as_app(BeerQuest::FB_APP_ID, BeerQuest::FB_SECRET)
    call = MiniFB.post(cred['access_token'], BeerQuest::FB_APP_ID, :type => 'accounts/test-users', :installed => 'true', :permissions => 'read_stream,publish_stream')
    if call['id']
      flash[:notice] = "Test account #{call['id']} created"
    else
      flash[:error] = call.inspect
    end
    redirect_to :controller => 'admin', :action => 'test_accounts'
  end

  private

  def admin_required
    Rails.env == 'development' || @admin
  end

  def check_restrictions
    logger.debug "Checking FB restrictions..."
    @restrictions = MiniFB.call(BeerQuest::FB_API_KEY, BeerQuest::FB_SECRET, 'admin.getRestrictionInfo', {'format' => 'JSON'})
    logger.debug "Raw restrictions are: #{@restrictions}"
    begin
      @restrictions.gsub!(/\\(.)/, '\1')
      @restrictions = @restrictions[1..-2]
      @restrictions = JSON.parse(@restrictions)
      logger.debug "Current restrictions are: #{@restrictions.inspect}"
    rescue JSON::ParserError => e
      logger.error "Error while parsing JSON restrictions: #{e}"
    end
    true
  end

  def set_restrictions
    restrictions = {:type => 'alcohol'}
    logger.debug "Setting FB restrictions to #{restrictions.to_json}..."
    res = MiniFB.call(BeerQuest::FB_API_KEY, BeerQuest::FB_SECRET, 'admin.setRestrictionInfo', {'restriction_str' => restrictions.to_json, 'format' => 'JSON'})
    unless res == 'true'
      logger.error "Unable to set FB restrictions"
    end
  end

end
