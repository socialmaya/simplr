Rails.application.routes.draw do
  resources :settings
  # user to user connections
  post 'users/:user_id/follow', to: 'connections#create', as: 'follow'
  delete 'users/:user_id/unfollow', to: 'connections#destroy', as: 'unfollow'
  get 'users/:user_id/following', to: 'connections#following', as: 'following'
  get 'users/:user_id/followers', to: 'connections#followers', as: 'followers'

  # user to group connections
  post 'groups/:group_id/request_to_join', to: 'connections#create', as: 'request_to_join'
  post 'users/:user_id/invite_to_join/:group_id', to: 'connections#create', as: 'invite_to_join'
  delete 'groups/:group_id/leave', to: 'connections#destroy', as: 'leave_group'
  delete 'users/:user_id/remove/:group_id', to: 'connections#destroy', as: 'remove_user'
  get 'groups/:group_id/members', to: 'connections#members', as: 'members'
  get 'users/:user_id/invites', to: 'connections#invites', as: 'invites'
  get 'group/:group_id/requests', to: 'connections#requests', as: 'requests'
  get 'users/:user_id/invite', to: 'connections#new', as: 'invite'
  get 'my_groups', to: 'connections#my_groups', as: 'my_groups'
  
  # settings
  put 'settings/update', as: 'update_settings'
  
  # messages
  get 'messages/add_image', as: 'add_message_image'
  get 'messages/instant_messages', to: 'messages#instant_messages'
  get 'groups/:group_id/chat', to: 'messages#index', as: 'group_chat'

  # sessions
  get 'sessions/new'
  post 'sessions/create', as: 'sessions'
  get 'sessions/destroy'

  # posts
  get 'posts/add_image', as: 'add_post_image'
  
  # comments
  get 'posts/:post_id/toggle_comments', to: 'comments#toggle_mini_index', as: 'toggle_comments'

  # notes
  get 'notes/index', as: 'notes'
  delete 'notes/destroy', as: 'clear_notes'

  # search
  get 'search', to: 'search#index', as: 'search'

  # pages
  get 'pages/scroll_to_top', as: 'scroll_to_top'
  get 'pages/toggle_menu', as: 'toggle_menu'
  get 'pages/more'

  resources :connections
  resources :messages
  resources :comments
  resources :groups
  resources :users
  resources :posts

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'posts#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
