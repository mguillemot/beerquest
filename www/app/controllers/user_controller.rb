class UserController < FacebookController

  BARS_PER_PAGE = 3
  WORLD_SCORE_TARGETS = [
          {:score => 1_000, :challenge => 'challenge.value.target1000'},
          {:score => 2_000, :challenge => 'challenge.value.target2000'},
          {:score => 5_000, :challenge => 'challenge.value.target5000'}
  ]

  def index
    async_world_score
    async_favorites
    async_partners
    async_search
  end

  def async_world_score
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

  def async_favorites
    results = @me.favorite_bars
    @favorites_page = (params[:page] || 1).to_i
    @favorites_max_page = (results.count.to_f / BARS_PER_PAGE).ceil
    @favorites_total = results.count
    @favorites = results.all(:limit => BARS_PER_PAGE, :offset => (@favorites_page - 1) * BARS_PER_PAGE)
  end

  def async_partners
    results = Bar.all
    @partners_page = (params[:page] || 1).to_i
    @partners_max_page = (results.count.to_f / BARS_PER_PAGE).ceil
    @partners_total = results.count
    @partners = results.all(:limit => BARS_PER_PAGE, :offset => (@partners_page - 1) * BARS_PER_PAGE)
  end

  def async_search
    @search_prefix = params[:prefix] || '(none)'
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
    if params[:page]
      @search_page = params[:page].to_i
    end
    if !@search_page || @search_page < 1 || @search_page > @search_max_page
      @search_page = 1
    end

    @search_total = results.count
    @search = results.all(:limit => BARS_PER_PAGE, :offset => (@search_page - 1) * BARS_PER_PAGE)
  end

end
