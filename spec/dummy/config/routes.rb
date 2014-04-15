Rails.application.routes.draw do
  mount OpenStax::Accounts::Engine => '/accounts'

  post 'oauth/token', :to => 'oauth#token'

  namespace :api do
    post 'dummy', :to => 'dummy#dummy'

    resource :application_users, :only => :create

    resource :users, :only => [] do
      get 'search'
    end
  end

  root :to => 'application#index'
end
