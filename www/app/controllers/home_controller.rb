require 'rss/2.0'

class HomeController < FacebookController

  BARS_PER_PAGE = 3

  def index
    @favorite_bars = WillPaginate::Collection.create(1, BARS_PER_PAGE) do |pager|
      result = Bar.all(:limit => pager.per_page, :offset => pager.offset)
      pager.replace(result)
    end

    @partner_bars = Bar.all

    @search_bars = []
  end

  def async_favorites
    @favorite_bars_page = params[:page].to_i
    @favorite_bars = (Bar.all)[((@favorite_bars_page - 1) * BARS_PER_PAGE)...(@favorite_bars_page * BARS_PER_PAGE)]
  end

  def bar
    @bar = Bar.get(params[:id])
    @required_version = "0.95"
    @mode = "solo"
    @replay = @me.replays.create(:bar => @bar, :token => ActiveSupport::SecureRandom.hex(16), :ip => request.remote_ip)
    unless @replay.saved?
      logger.error "Impossible to create replay because of the following errors:"
      @replay.errors.each do |e|
        logger.error "ERROR: #{e}"
      end
    end

    @barship = @me.barships.first(:bar => @bar)

    if @bar.rss
      @rss = []
      begin
        open(@bar.rss) do |http|
          response = http.read
          result = RSS::Parser.parse(response, false)
          result.items[0..10].each do |item|
            @rss << {:title => item.title, :content => item.description, :url => item.link, :date => item.pubDate}
          end
        end
      rescue OpenURI::HTTPError
        logger.error "Unable to open RSS stream #{@bar.rss}"
        @rss = nil
      end
    end
  end

  def help
  end

  def privacy
  end

  def tos
  end

end
