class UserController < FacebookController

  BARS_PER_PAGE = 3

  def index
    async_favorites
    async_partners
    async_search
  end

  def async_favorites
    results = Bar.all
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
