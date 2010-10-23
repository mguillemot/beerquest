BeerQuest::Application.routes.draw do

  # User pages
  root                              :to => "user#index",                     :as => 'home'
  get "world-score",                :to => "user#async_world_score",         :as => 'async_world_score'
  get "bars/favorites/:page",       :to => "user#async_favorites",           :as => 'async_favorites'
  get "bars/partners/:page",        :to => "user#async_partners",            :as => 'async_partners'
  get "bars/search/:prefix/:page",  :to => "user#async_search",              :as => 'async_search'
  get "challenges/current/:page",   :to => "user#async_current_challenges",  :as => 'async_current_challenges'
  get "challenges/sent/:page",      :to => "user#async_current_challenges",  :as => 'async_sent_challenges'
  get "challenges/received/:page",  :to => "user#async_received_challenges", :as => 'async_received_challenges'
  get "invite",                     :to => "user#invite",                    :as => 'invite'

  # Bar pages
  get "bar/:id",                    :to => "bar#index",                      :as => 'bar'

  # Static pages
  get "privacy",                    :to => "static#privacy",                 :as => 'privacy'
  get "tos",                        :to => "static#tos",                     :as => 'tos'

  # Facebook integration
  get "session_login",              :to => "facebook#session_login",         :as => 'login'
  get "session_logout",             :to => "facebook#session_logout",        :as => 'logout'

  # Game integration
  post "start",                     :to => "game#start",                     :as => 'game_start'
  post "postscore",                 :to => "game#postscore",                 :as => 'post_score'
  post "end",                       :to => "game#end",                       :as => 'game_end'

  # Donations
  get "support_us",                 :to => "payment#index",                  :as => 'support_us'
  post "support_us/donate/:level",  :to => "payment#donate",                 :as => 'donate'
  get "support_us/enddonate/:id",   :to => "payment#end",                    :as => 'end_donate'

  # Admin & debug
  get "play/:id" ,                  :to => "admin#hack_login"
  get "debug/:id",                  :to => "admin#check_game"

end
