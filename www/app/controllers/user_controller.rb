class UserController < FacebookController

  protect_from_forgery :except => [:index, :invite_end] # index: canvas POST

  BARS_PER_PAGE = 3
  INVITE_MESSAGES = 3

  def index
    unless @me.first_login
      # User's first login: send him to the default bar
      logger.debug "This is account #{@me.id} (#{@me.full_name}) first time here!"
      @me.first_login = DateTime.now
      @me.save
      redirect_to bar_url(@me.last_bar)
      return true
    end

    @nav = 'home'
#    set_favorites(1)
#    set_partners(1)
#    set_search('(none)', 1)
  end

  def async_world_score
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

  def invite
    @nav     = 'challenge'
    @exclude = @me.already_invited_friends_fbids
    @invite  = 1 + rand(INVITE_MESSAGES)
  end

  def invite_end
    logger.info "Sent invites (msg=#{params[:msg]}, lang=#{I18n.locale}) to the following users: #{params[:ids].inspect}"
    if params[:ids]
      params[:ids].each do |id|
        @me.invites.create(:friend_facebook_id => id, :message => params[:msg], :lang => I18n.locale)
      end
    end
    redirect_to home_url
  end

  protected

  def set_favorites(page)
    results             = @me.favorite_bars
    @favorites_page     = page
    @favorites_max_page = [1, (results.count.to_f / BARS_PER_PAGE).ceil].max
    @favorites_total    = results.count
    @favorites          = results.all(:limit => BARS_PER_PAGE, :offset => (@favorites_page - 1) * BARS_PER_PAGE)
  end

  def set_partners(page)
    results            = Bar.all
    @partners_page     = page
    @partners_max_page = [1, (results.count.to_f / BARS_PER_PAGE).ceil].max
    @partners_total    = results.count
    @partners          = results.all(:limit => BARS_PER_PAGE, :offset => (@partners_page - 1) * BARS_PER_PAGE)
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
    @search_page     = page
    if !@search_page || @search_page < 1 || @search_page > @search_max_page
      @search_page = 1
    end

    @search_total = results.count
    @search       = results.all(:limit => BARS_PER_PAGE, :offset => (@search_page - 1) * BARS_PER_PAGE)
  end

end
