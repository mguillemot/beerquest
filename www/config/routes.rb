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
  match "invite-done",              :to => "user#invite_end",                :as => 'invite_end'
  get "challenge/:id",              :to => "user#challenge",                 :as => 'challenge'
  get "challenge/:id/messages",     :to => "user#async_challenge_messages",  :as => 'async_challenge_messages'
  get "accept-challenge/:id",       :to => "user#accept_challenge",          :as => 'accept_challenge'
  get "refuse-challenge/:id",       :to => "user#refuse_challenge",          :as => 'refuse_challenge'
  get "start-challenge/:id",        :to => "user#start_challenge",           :as => 'start_challenge'

  # Bar pages
  get "bar/:id",                    :to => "bar#index",                      :as => 'bar'
  get "bar/:id/messages",           :to => "bar#async_messages",             :as => 'async_bar_messages'

  # Facebook integration
  get "session_login",              :to => "facebook#session_login",         :as => 'login'
  get "session_logout",             :to => "facebook#session_logout",        :as => 'logout'

  # Game integration
  post "start",                     :to => "game#start",                     :as => 'game_start'
  post "postscore",                 :to => "game#postscore",                 :as => 'post_score'
  post "end",                       :to => "game#end",                       :as => 'game_end'
  post "message",                   :to => "game#message",                   :as => 'endgame_message'

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
