# Be sure to restart your server when you modify this file.

#BeerQuest::Application.config.session_store :cookie_store, :key => '_BeerQuest_session'

redis_config                   = YAML::load_file("#{Rails.root}/config/redis.yml")
redis_env_config               = redis_config[Rails.env]
BeerQuest::Application.config.session_store :redis_session_store,
                                            :key          => 'SID',
                                            :host         => redis_env_config['host'],
                                            :port         => redis_env_config['port'],
                                            :db           => 1,
                                            :expire_after => 1.hour