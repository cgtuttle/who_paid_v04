Rails.application.routes.draw do

  get 'account_mailers/index'

  get 'account_mailers/show'

  devise_for :users, path_prefix: 'authenticate'

  devise_scope :user do
    get '/users/send_invitation/:id', to: 'users/invitations#deliver', as: 'send_user_invitation'
    get '/users/create_invitations/:id', to: 'users/invitations#create', as: 'create_user_invitation'
    get '/new_guest', to: 'users#new_guest', as: 'new_guest'
  end

  get '/visitors/welcome' => 'visitors#welcome', as: 'welcome'
  get '/visitors/learn' => 'visitors#learn', as: 'learn_more'
  get '/payments/delete/:id' => 'payments#set_delete', as: 'delete_payment'
  get '/payments/update_allocations/:id' => 'payments#update_allocations', as: "update_allocations"
  get '/users/new(/:id)', to: 'users#new', as: 'new_user'

  resources :events do
    resources :accounts do
      get 'event_statement', as: 'statement'
      get 'statement_email'
      collection do
        get 'statements_email'
      end
    end
    post 'accounts/create'
    post 'memberships/create'
    resources :users do
      get 'memberships/destroy'
      post 'memberships/create'
    end
    resources :payments
  end

  resources :users do
    resources :payments
  end

  resources :payments
  
  resources :accounts do
    get 'statement'
    get 'statement_email'
  end

  resources :allocations
  resources :memberships

  root 'visitors#welcome'


end
