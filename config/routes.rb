Rails.application.routes.draw do

  root 'visitors#welcome'

  devise_for :users

  devise_scope :user do
    get '/users/send_invitation/:id', to: 'users/invitations#deliver', as: 'send_user_invitation'
    get '/users/create_invitations/:id', to: 'users/invitations#create', as: 'create_user_invitation'
  end

  get '/visitors/welcome' => 'visitors#welcome', as: 'welcome'
  get '/visitors/learn' => 'visitors#learn', as: 'learn_more'

  resources :events do
    resources :accounts
    post 'accounts/create'
    resources :payments
  end

  resources :payments

  resources :users

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

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
