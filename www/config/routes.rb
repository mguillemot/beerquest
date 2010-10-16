BeerQuest::Application.routes.draw do

  # User pages
  root                         :to => "user#index",             :as => 'home'
  get "world-score",          :to => "user#async_world_score", :as => 'async_world_score'
  get "favorites/:page",      :to => "user#async_favorites",   :as => 'async_favorites'
  get "partners/:page",       :to => "user#async_partners",    :as => 'async_partners'
  get "search/:prefix/:page", :to => "user#async_search",      :as => 'async_search'

  # Bar pages
  get "bar/:id",              :to => "bar#index",              :as => 'bar'

  # Static pages
  get "support_us",           :to => "static#support_us",      :as => 'support_us'
  get "privacy",              :to => "static#privacy",         :as => 'privacy'
  get "tos",                  :to => "static#tos",             :as => 'tos'

  # Facebook integration
  get "session_login",       :to => "facebook#session_login",  :as => 'login'
  get "session_logout",      :to => "facebook#session_logout", :as => 'logout'

  # Game integration
  get "start",               :to => "game#start",              :as => 'game_start'
  post "postscore",          :to => "game#postscore",          :as => 'post_score'

  # Admin & debug
  get "play/:id" ,           :to => "admin#hack_login"
  get "debug/:id",           :to => "admin#check_game"

end
