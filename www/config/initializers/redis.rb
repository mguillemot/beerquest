require 'redis'

module BeerQuest
  Application.configure do
    @redis = Redis.new(:host => "192.168.1.100")
  end
end