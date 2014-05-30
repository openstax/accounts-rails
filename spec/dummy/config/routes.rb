Rails.application.routes.draw do
  mount OpenStax::Accounts::Engine => '/accounts'

  post 'oauth/token', :to => 'oauth#token'

  namespace :api do
    post 'dummy', :to => 'dummy#dummy'

    resources :application_users, :only => [:index, :create] do
      collection do
        get 'updates'
        put 'updated'
      end
    end
  end

  root :to => 'application#index'
end
