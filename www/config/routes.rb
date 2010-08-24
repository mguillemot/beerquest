BeerQuest::Application.routes.draw do

  # Facebook integration
  get "session_login", :to => "facebook#session_login", :as => 'login'
  get "session_logout", :to => "facebook#session_logout", :as => 'logout'
  get "play/:id", :to => "facebook#hack_login" # TODO virer quand vraie intégration FB

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

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
#  resources :account
#  resources :scores

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
