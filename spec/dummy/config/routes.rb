Rails.application.routes.draw do
  root :to => 'application#index'

  mount OpenStax::Accounts::Engine => '/accounts'

  post 'oauth/token', :to => 'oauth#token'

  namespace :api do
    post 'dummy', :to => 'dummy#dummy'

    resources :users, :only => [:index]

    resources :application_users, :only => [:index] do
      collection do
        get 'updates'
        put 'updated'
      end
    end
  end
end
