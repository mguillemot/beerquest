BeerQuest::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Deprecation notices
  config.active_support.deprecation = :log

  # PayPal
  PAYPAL_API_URL = 'https://api-3t.sandbox.paypal.com/nvp'
  PAYPAL_USER_URL = 'https://www.sandbox.paypal.com/webscr&cmd=_express-checkout'
  PAYPAL_USER = 'payment_api1.touhou-shop.com'
  PAYPAL_PWD = 'KN6K3KLXBDQTLHQ3'
  PAYPAL_SIGNATURE = 'AbGhBFISPjSS9ZCvaXavWffxEvTzA28ZuQSusINMThFA7UKPV.QVZIXY'
end
