class HomeController < FacebookController
  def index
  end

  def bar
    @bar = Bar.get(params[:id])
    @required_version = "0.8"
    @mode = "solo"
    replay = @account.replays.create(:bar => @bar, :token => ActiveSupport::SecureRandom.hex(16), :ip => request.remote_ip)
    @token = replay.token
  end

  def help
  end

  def privacy
  end

  def tos
  end
end
