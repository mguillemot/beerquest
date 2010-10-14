BeerQuest::Application.routes.draw do

  # Bar pages
  root                    :to => "home#index",             :as => 'home'
  get "async_fav/:page", :to => "home#async_favorites",   :as => 'async_favorites'
  get "bar/:id",         :to => "home#bar",               :as => 'bar'
  get "help",            :to => "home#help",              :as => 'help'
  get "privacy",         :to => "home#privacy",           :as => 'privacy'
  get "tos",             :to => "home#tos",               :as => 'tos'

  # Facebook integration
  get "session_login",  :to => "facebook#session_login",  :as => 'login'
  get "session_logout", :to => "facebook#session_logout", :as => 'logout'

  # Game integration
  get "start",          :to => "game#start",              :as => 'game_start'
  post "postscore",     :to => "game#postscore",          :as => 'post_score'

  # Admin & debug
  get "play/:id" ,      :to => "admin#hack_login"
  get "debug/:id",      :to => "admin#check_game"

end
