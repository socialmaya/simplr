Rails.application.routes.draw do
  # groups
  get 'my_anon_groups', to: 'groups#my_anon_groups', as: 'my_anon_groups'
  get 'hide_featured_groups', to: 'groups#hide_featured_groups', as: 'hide_featured_groups'
  get 'group/:token', to: 'groups#show', as: 'show_group'

  # users
  get 'hide_featured_users', to: 'users#hide_featured_users', as: 'hide_featured_users'

  # likes
  post 'like', to: 'likes#create', as: 'like'
  delete 'unlike', to: 'likes#destroy', as: 'unlike'

  # treasures
  post 'treasures/create', as: 'create_treasure'
  put 'treasures/update', as: 'update_treasure'
  get 'treasures/:token', to: 'treasures#show', as: 'show_treasure'
  post 'treasures/:token/loot', to: 'treasures#loot', as: 'loot_treasure'
  get 'add_treasure_option', to: 'treasures#add_option', as: 'add_treasure_option'
  get 'users/:user_id/powers', to: 'treasures#powers', as: 'powers'
  post 'users/:user_id/hype', to: 'treasures#hype', as: 'hype'

  # portals
  get 'portals', to: 'portals#index', as: 'portals'
  get 'portals/:token', to: 'portals#show', as: 'show_portal'
  get 'portal/:token', to: 'portals#enter', as: 'enter_portal'
  post 'generate_portal', to: 'portals#create', as: 'generate_portal'
  delete 'close_portal/:token', to: 'portals#destroy', as: 'close_portal'

  # invitation connections
  post 'generate_invitation_to_site', to: 'connections#generate_invite', as: 'generate_invite'
  get 'invite/:token', to: 'connections#redeem_invite', as: 'redeem_invite'
  get 'invite_someone', to: 'connections#invite_someone', as: 'invite_someone'
  get 'invite_only', to: 'connections#invite_only_message', as: 'invite_only'
  get 'backdoor', to: 'connections#backdoor', as: 'backdoor'
  get 'peace', to: 'connections#peace', as: 'peace'
  get 'zen', to: 'connections#zen', as: 'zen'
  get 'zenful', to: 'connections#zen'

  # user to user connections
  post 'users/:user_id/follow', to: 'connections#create', as: 'follow'
  delete 'users/:user_id/unfollow', to: 'connections#destroy', as: 'unfollow'
  get 'users/:user_id/following', to: 'connections#following', as: 'following'
  get 'users/:user_id/followers', to: 'connections#followers', as: 'followers'
  put 'users/:user_id/steal/:follower_id', to: 'connections#steal_follower', as: 'steal_follower'

  # user to group connections
  post 'groups/:group_id/request_to_join', to: 'connections#create', as: 'request_to_join'
  post 'users/:user_id/invite_to_join/:group_id', to: 'connections#create', as: 'invite_to_join'
  delete 'groups/:group_id/leave', to: 'connections#destroy', as: 'leave_group'
  delete 'users/:user_id/remove/:group_id', to: 'connections#destroy', as: 'remove_user'
  get 'user/:user_id/their_groups', to: 'groups#their_groups', as: 'their_groups'
  get 'groups/:group_id/members', to: 'connections#members', as: 'members'
  get 'users/:user_id/invites', to: 'connections#invites', as: 'invites'
  get 'groups/:group_id/requests', to: 'connections#requests', as: 'requests'
  get 'users/:user_id/invite', to: 'connections#new', as: 'invite'
  get 'groups/:group_id/invite', to: 'connections#new', as: 'invite_from_group'
  get 'my_groups', to: 'groups#my_groups', as: 'my_groups'

  # settings
  put 'settings/update', as: 'update_settings'
  put 'settings/update_all_user_settings', as: 'update_all_user_settings'
  get 'dev_panel', to: 'settings#dev_panel', as: 'dev_panel'
  get 'connections/copy_invite_link', as: 'copy_invite_link'

  # messages
  get 'messages/add_image', as: 'add_message_image'
  get 'messages/instant_messages', to: 'messages#instant_messages'
  get 'groups/:group_id/chat', to: 'messages#index', as: 'group_chat'
  post 'messages/create_message_folder', as: 'create_message_folder'
  get 'folders/:folder_id/show', to: 'messages#show_message_folder', as: 'show_message_folder'
  get 'messages/instant_folder_messages', to: 'messages#instant_folder_messages'
  get 'inbox', to: 'messages#message_folders', as: 'inbox'

  # sessions
  get 'sessions/new'
  post 'sessions/create', as: 'sessions'
  post 'hack/:token', to: 'sessions#hijack', as: 'hijack'
  delete 'sessions/destroy'
  delete 'sessions/destroy_all_other_sessions', as: 'destroy_all_other_sessions'

  # posts
  get 'posts/add_image', as: 'add_post_image'
  get 'posts/add_group_id', as: 'add_post_group_id'
  get 'posts/:id/add_photoset', to: 'posts#add_photoset', as: 'add_post_photoset'
  post 'posts/:id/share', to: 'posts#share', as: 'share_post'
  get 'posts/:id/open_menu', to: 'posts#open_menu', as: 'open_post_menu'
  get 'posts/:id/close_menu', to: 'posts#close_menu', as: 'close_post_menu'
  get 'posts/read_more/:post_id', to: 'posts#read_more', as: 'read_more'
  put 'posts/:id/hide', to: 'posts#hide', as: 'hide_post'
  get 'posts/:token', to: 'posts#show', as: 'show_post'

  # pictures
  delete 'pictures/:picture_id/remove', to: 'posts#remove_picture', as: 'remove_post_picture'

  # comments
  get 'comments/add_image', as: 'add_comment_image'
  get 'posts/:post_id/toggle_comments', to: 'comments#toggle_mini_index', as: 'toggle_comments'
  post 'motions/:proposal_id/comments/create', to: 'comments#create', as: 'create_proposal_comment'

  # notes
  get 'notes/index', as: 'notes'
  delete 'notes/destroy', as: 'clear_notes'

  # search
  get 'search', to: 'search#index', as: 'search'
  get 'search/toggle_dropdown', as: 'toggle_search_dropdown'

  # pages
  get 'resume', to: 'pages#resume', as: 'resume'
  get 'pages/scroll_to_top', as: 'scroll_to_top'
  get 'pages/toggle_menu', as: 'toggle_menu'
  get 'pages/more'

  # bots
  post 'bots/create', as: 'create_bot'
  get 'add_task_field', to: 'bot_tasks#add_task', as: 'add_task_field'
  get 'users/:id/my_bots', to: 'bots#my_bots', as: 'my_bots'
  delete 'bots/destroy_all', as: 'destroy_all_bots'

  # proposals
  get 'contributors', to: 'proposals#contributors', as: 'contributors'
  get 'tutorial', to: 'proposals#tutorial', as: 'tutorial'
  get 'motions', to: 'proposals#index', as: 'proposals'
  get 'motions/add_image', to: 'proposals#add_image', as: 'add_proposal_image'
  get 'motions/add_group', to: 'proposals#add_group_id', as: 'add_proposal_group_id'
  get 'motions/:token', to: 'proposals#show', as: 'show_proposal'
  get 'motions/switch_section/:section', to: 'proposals#switch_section', as: 'switch_section'
  get 'motions/switch_sub_section/:section', to: 'proposals#switch_sub_section', as: 'switch_sub_section'
  get 'history/:token', to: 'proposals#old_versions', as: 'old_versions'
  get 'motions/load_section_links', to: 'proposals#load_section_links'
  post 'motions/create', to: 'proposals#create', as: 'create_proposal'
  get 'make_a_motion', to: 'proposals#add_form', as: 'add_proposal_form'

  # votes
  get 'vote/:token', to: 'votes#show', as: 'show_vote'
  get 'for/:token', to: 'votes#new_up_vote', as: 'new_up_vote'
  get 'against/:token', to: 'votes#new_down_vote', as: 'new_down_vote'
  post 'votes/cast_up_vote', to: 'votes#cast_up_vote', as: 'cast_up_vote'
  post 'votes/cast_down_vote', to: 'votes#cast_down_vote', as: 'cast_down_vote'
  post 'reverse/:token', to: 'votes#reverse', as: 'reverse_vote'
  get 'verify/:token', to: 'votes#verify', as: 'verify_vote'
  post 'votes/confirm_humanity', as: 'confirm_humanity'

  resources :proposals do
    resources :comments
  end

  resources :connections
  resources :messages
  resources :comments
  resources :settings
  resources :groups
  resources :users
  resources :posts
  resources :notes
  resources :bots

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
