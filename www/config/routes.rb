BeerQuest::Application.routes.draw do

  # Facebook integration
  get "session_login", :to => "facebook#session_login", :as => 'login'
  get "session_logout", :to => "facebook#session_logout", :as => 'logout'
  get "play/:id", :to => "facebook#hack_login" # TODO virer quand vraie int�gration FB

  # Game pages
  root :to => "home#index", :as => 'home'
  get "bar/:id", :to => "home#bar", :as => 'bar'

  # Static pages
  get "help", :to => "home#help", :as => 'help'
  get "privacy", :to => "home#privacy", :as => 'privacy'
  get "tos", :to => "home#tos", :as => 'tos'

  # Game integration
  get "start", :to => "scores#start", :as => 'game_start'
  post "postscore", :to => "scores#postscore", :as => 'post_score'

  # Test pages
  get "debug/:id", :to => "facebook#test"

end
