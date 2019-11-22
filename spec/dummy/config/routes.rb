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

    resources :application_users, only: [:index] do
      collection do
        get 'updates'
        put 'updated'
      end
    end
  end
end
