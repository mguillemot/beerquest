require 'rss/2.0'

class HomeController < FacebookController
  def index
  end

  def bar
    @bar = Bar.get(params[:id])
    @required_version = "0.91"
    @mode = "solo"
    @replay = @account.replays.create(:bar => @bar, :token => ActiveSupport::SecureRandom.hex(16), :ip => request.remote_ip)
    unless @replay.saved?
      logger.error "Impossible to create replay because of the following errors:"
      @replay.errors.each do |e|
        logger.error "ERROR: #{e}"
      end
    end

    @barship = @account.barships.first(:bar => @bar)

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
