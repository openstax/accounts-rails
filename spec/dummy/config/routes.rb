Rails.application.routes.draw do
  mount OpenStax::Accounts::Engine => '/accounts'

  post 'oauth/token', :to => 'oauth#token'

  namespace :api do
    post 'dummy', :to => 'dummy#dummy'

    resources :application_users, :only => [:index, :create]
  end

  root :to => 'application#index'
end
