Rails.application.routes.draw do

  root :to => 'application#index'

  mount OpenStax::Accounts::Engine => '/accounts'

  post 'oauth/token', :to => 'oauth#token'

  namespace :api do

    post 'dummy', :to => 'dummy#dummy'

    resources :users, :only => [:index, :update]

    resources :groups, :only => [:create, :update, :destroy] do
      resources :group_members, :only => [:create, :destroy], :shallow => true
      resources :group_owners, :only => [:create, :destroy], :shallow => true
      resources :group_nestings, :only => [:create, :destroy], :shallow => true
    end

    resources :application_users, :only => [:index] do
      collection do
        get 'updates'
        put 'updated'
      end
    end

    resources :application_groups, :only => [] do
      collection do
        get 'updates'
        put 'updated'
      end
    end

  end

end
