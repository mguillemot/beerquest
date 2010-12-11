BeerQuest::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  #config.action_dispatch.x_sendfile_header = "X-Sendfile"
  # For nginx:
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :warn

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # PayPal
  PAYPAL_API_URL = 'https://api-3t.paypal.com/nvp'
  PAYPAL_USER_URL = 'https://www.paypal.com/webscr&cmd=_express-checkout'
  PAYPAL_USER = 'give-a-beer_api1.bq-4.com'
  PAYPAL_PWD = 'KR39A42AXSEL35D9'
  PAYPAL_SIGNATURE = 'ArVdpMVnoHAB1wJcXUBJ3rZDw55OAMw6Dxzv3iHFxxAh4QplxiWYWPRj'

  # Redis
  REDIS_HOST = "127.0.0.1"
  REDIS_PORT = "6379"
end
