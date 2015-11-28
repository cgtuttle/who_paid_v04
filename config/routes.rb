Rails.application.routes.draw do

#  devise_for :users, controllers: { registrations: 'users', invitations: 'users/invitations'  }
  devise_for :users, controllers: { invitations: 'users/invitations'  }

  devise_scope :user do
    get '/users/send_invitation/:id', to: 'users/invitations#deliver', as: 'send_user_invitation'
    get '/users/create_invitations/:id', to: 'users/invitations#create', as: 'create_user_invitation'
  end

  get '/visitors/welcome' => 'visitors#welcome', as: 'welcome'
  get '/visitors/learn' => 'visitors#learn', as: 'learn_more'
  get '/payments/delete/:id' => 'payments#set_delete', as: 'delete_payment'
  get '/payments/update_allocations/:id' => 'payments#update_allocations', as: "update_allocations"
  get '/users/new_from_account/:id', to: 'users#new_from_account', as: 'new_user_from_account'

  resources :events do
    resources :accounts
    post 'accounts/create'
    resources :payments
  end

  resources :payments
  resources :accounts
  resources :users
  resources :allocations

  root 'visitors#welcome'


end
