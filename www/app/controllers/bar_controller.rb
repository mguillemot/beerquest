require 'rss/2.0'

class BarController < FacebookController

  def index
    @bar = Bar.get!(params[:id])
    @mode = "solo"
    logger.debug "Creating solo replay for user #{@me.inspect} in bar #{@bar.inspect}"
    @replay = @me.replays.create(:bar => @bar, :token => ActiveSupport::SecureRandom.hex(16), :ip => request.remote_ip, :mode => 'solo')
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

  def async_messages
    logger.debug "Récupération du bar #{params[:id]}..."
    @bar = Bar.get!(params[:id])
    logger.debug "Messages for bar #{@bar.inspect}"
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
