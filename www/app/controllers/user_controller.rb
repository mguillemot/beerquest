class UserController < FacebookController

  BARS_PER_PAGE = 3
  CHALLENGES_PER_PAGE = 8
  WORLD_SCORE_TARGETS = [
          {:score => 1_000, :challenge => 'challenge.value.target1000'},
          {:score => 2_000, :challenge => 'challenge.value.target2000'},
          {:score => 5_000, :challenge => 'challenge.value.target5000'}
  ]

  def index
    set_world_score
    set_favorites(1)
    set_partners(1)
    set_search('(none)', 1)
    set_current_challenges(1)
    set_received_challenges(1)
    set_sent_challenges(1)
  end

  def async_world_score
    set_world_score
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def async_favorites
    set_favorites(params[:page].to_i)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def async_partners
    set_partners(params[:page].to_i)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def async_search
    set_search(params[:prefix], params[:page].to_i)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def async_current_challenges
    set_current_challenges(params[:page].to_i)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def async_received_challenges
    set_received_challenges(params[:page].to_i)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def async_sent_challenges
    set_sent_challenges(params[:page].to_i)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def invite
    @exclude = []
    @me.already_challenging_people.each do |account|
      @exclude.push(account.facebook_id) if account.facebook_id
    end
  end

  def challenge
    @challenge = Challenge.get! params[:id]
    @required_version = Game::Constants::VERSION
    @mode = "vs"
    @replay = @me.replays.create(:token => ActiveSupport::SecureRandom.hex(16), :ip => request.remote_ip, :mode => 'vs', :challenge => @challenge)
  end

  protected

  def set_world_score
    @world_score = World.total_beers
    @world_score_increase = World.increase_last_hour / 3600.0
    target = WORLD_SCORE_TARGETS.find { |t| t[:score] > @world_score }
    if target
      @world_score_target = target[:score]
      @world_score_action = t(target[:challenge])
    else
      @world_score_target = 0
      @world_score_action = ''
    end
  end

  def set_favorites(page)
    results = @me.favorite_bars
    @favorites_page = page
    @favorites_max_page = [1, (results.count.to_f / BARS_PER_PAGE).ceil].max
    @favorites_total = results.count
    @favorites = results.all(:limit => BARS_PER_PAGE, :offset => (@favorites_page - 1) * BARS_PER_PAGE)
  end

  def set_partners(page)
    results = Bar.all
    @partners_page = page
    @partners_max_page = [1, (results.count.to_f / BARS_PER_PAGE).ceil].max
    @partners_total = results.count
    @partners = results.all(:limit => BARS_PER_PAGE, :offset => (@partners_page - 1) * BARS_PER_PAGE)
  end

  def set_search(prefix, page)
    @search_prefix = prefix
    if @search_prefix == '123'
      results = Bar.all(:name.like => "1%") +
              Bar.all(:name.like => "2%") +
              Bar.all(:name.like => "3%") +
              Bar.all(:name.like => "4%") +
              Bar.all(:name.like => "5%") +
              Bar.all(:name.like => "6%") +
              Bar.all(:name.like => "7%") +
              Bar.all(:name.like => "8%") +
              Bar.all(:name.like => "9%") +
              Bar.all(:name.like => "0%")
    else
      results = Bar.all(:name.like => "#{@search_prefix}%")
    end

    @search_max_page = [1, (results.count.to_f / BARS_PER_PAGE).ceil].max
    @search_page = page
    if !@search_page || @search_page < 1 || @search_page > @search_max_page
      @search_page = 1
    end

    @search_total = results.count
    @search = results.all(:limit => BARS_PER_PAGE, :offset => (@search_page - 1) * BARS_PER_PAGE)
  end

  def set_current_challenges(page)
    results = @me.current_challenges
    @current_challenges_page = page
    @current_challenges_max_page = [1, (results.count.to_f / CHALLENGES_PER_PAGE).ceil].max
    @current_challenges_total = results.count
    @current_challenges = results.all(:limit => CHALLENGES_PER_PAGE, :offset => (@current_challenges_page - 1) * CHALLENGES_PER_PAGE)
  end

  def set_received_challenges(page)
    results = @me.new_received_challenges
    @received_challenges_page = page
    @received_challenges_max_page = [1, (results.count.to_f / CHALLENGES_PER_PAGE).ceil].max
    @received_challenges_total = results.count
    @received_challenges = results.all(:limit => CHALLENGES_PER_PAGE, :offset => (@received_challenges_page - 1) * CHALLENGES_PER_PAGE)
  end

  def set_sent_challenges(page)
    results = @me.new_sent_challenges
    @sent_challenges_page = page
    @sent_challenges_max_page = [1, (results.count.to_f / CHALLENGES_PER_PAGE).ceil].max
    @sent_challenges_total = results.count
    @sent_challenges = results.all(:limit => CHALLENGES_PER_PAGE, :offset => (@sent_challenges_page - 1) * CHALLENGES_PER_PAGE)
  end

end
