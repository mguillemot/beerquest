# Be sure to restart your server when you modify this file.

#Rails.application.config.session_store :cookie_store, :key => '_BeerQuest_session'
require "redis-store"
Rails.application.config.session_store :redis_session_store, :host => "192.168.1.100"

