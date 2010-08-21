require 'mini_fb'

module BeerQuest
  Application.configure do
    FB_APP_ID = "135204849839083"
    FB_API_KEY = "0afdbede62875307ab1210c209948428"
    FB_SECRET = "82b5a1b0090bdff790e6527ae9ee0349"
    FB_BASE_URL = "http://erhune.iobb.net:81/fb"
    FB_APP_URL = "http://apps.facebook.com/beerquest/"

    MiniFB.enable_logging
  end
end