class HomeController < FacebookController
  def index
  end

  def play
    bar = Bar.find(1)
    # TODO (Erhune) paramétriser ça
    @required_version = "0.8"
    @mode = "solo"
    replay = @account.replays.create(:token => ActiveSupport::SecureRandom.hex(32), :ip => request.remote_ip)
    @token = replay.token
  end

  def help
  end

  def privacy
  end

  def tos
  end
end
