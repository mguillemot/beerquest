BeerQuest::Application.routes.draw do

  # User pages
  root                               :to => "user#index",                     :as => 'home', :via => [:get, :post] # Canvas POST
  get "world-score",                :to => "user#async_world_score",         :as => 'async_world_score'
  get "bars/favorites/:page",       :to => "user#async_favorites",           :as => 'async_favorites'
  get "bars/partners/:page",        :to => "user#async_partners",            :as => 'async_partners'
  get "bars/search/:prefix/:page",  :to => "user#async_search",              :as => 'async_search'
  get "challenges/current/:page",   :to => "user#async_current_challenges",  :as => 'async_current_challenges'
  get "challenges/sent/:page",      :to => "user#async_current_challenges",  :as => 'async_sent_challenges'
  get "invite",                     :to => "user#invite",                    :as => 'invite'
  match "invite-done",              :to => "user#invite_end",                :as => 'invite_end', :via => [:get, :post]
  get "challenge/:id",              :to => "user#challenge",                 :as => 'challenge'
  get "challenge/:id/messages",     :to => "user#async_challenge_messages",  :as => 'async_challenge_messages'
  match "accept-challenge/:id",       :to => "user#accept_challenge",          :as => 'accept_challenge', :via => [:get, :post] # Canvas POST
  match "refuse-challenge/:id",       :to => "user#refuse_challenge",          :as => 'refuse_challenge', :via => [:get, :post] # Canvas POST
  post "start-challenge/:id",       :to => "user#start_challenge",           :as => 'start_challenge'

  # Bar pages
  get "bar/:id",                    :to => "bar#show",                       :as => 'bar'
  get "bar/:id/messages",           :to => "bar#async_messages",             :as => 'async_bar_messages'

  # Tutorial
  get "tutorial/:page",             :to => "tutorial#index",                 :as => 'tutorial'

  # Facebook integration
  get "session_login",              :to => "facebook#session_login",         :as => 'login'
  get "session_logout",             :to => "facebook#session_logout",        :as => 'logout'
  
  # Monitoring
  get "health",                     :to => "monitoring#health",              :as => 'monitoring'

  # Game integration
  post "start",                     :to => "game#start",                     :as => 'game_start'
  post "postscore",                 :to => "game#postscore",                 :as => 'post_score'
  post "end",                       :to => "game#end",                       :as => 'game_end'
  post "message",                   :to => "game#message",                   :as => 'endgame_message'
  post "postwall",                  :to => "game#postwall",                  :as => 'postwall'

  # Donations
  get "support-us",                 :to => "payment#index",                  :as => 'support_us'
  post "support-us/donate/:level",  :to => "payment#donate",                 :as => 'donate'
  get "support-us/enddonate/:id",   :to => "payment#end",                    :as => 'end_donate'

  # Admin & debug
  get "admin/log-as/:id" ,          :to => "admin#log_as"
  get "admin/check-game/:id",       :to => "admin#check_game"
  get "admin/test_accounts",        :to => "admin#test_accounts"
  post "admin/new_test_account",    :to => "admin#new_test_account"

end
