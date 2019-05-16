Rails.application.routes.draw do

  root to: 'application#index'

  mount OpenStax::Accounts::Engine => '/accounts'

  post 'oauth/token', to: 'oauth#token'

  namespace :api do

    post 'dummy', to: 'dummy#dummy'

    resources :users, only: [:index]
    resource :user, only: [:update] do
      post 'find-or-create', to: 'users#create'
    end

    resources :groups, only: [:show, :create, :update, :destroy] do
      post '/members/:user_id', to: 'group_members#create'
      delete '/members/:user_id', to: 'group_members#destroy'

      post '/owners/:user_id', to: 'group_owners#create'
      delete '/owners/:user_id', to: 'group_owners#destroy'

      post '/nestings/:member_group_id', to: 'group_nestings#create'
      delete '/nestings/:member_group_id', to: 'group_nestings#destroy'
    end

    resources :application_users, only: [:index] do
      collection do
        get 'updates'
        put 'updated'
      end
    end

    resources :application_groups, only: [] do
      collection do
        get 'updates'
        put 'updated'
      end
    end

  end

end
