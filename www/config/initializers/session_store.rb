# Be sure to restart your server when you modify this file.

#BeerQuest::Application.config.session_store :cookie_store, :key => '_BeerQuest_session'

BeerQuest::Application.config.session_store :redis_session_store,
                                            :key => "SID", # name of cookie on client side
                                            :servers => [
                                                    {:host => "192.168.1.100", :db => 1}
                                            ],
                                            :expire_after => 1.hour
