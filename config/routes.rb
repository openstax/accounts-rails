OpenStax::Accounts::Engine.routes.draw do

  root :to => 'sessions#new'

  resource :session, :only => [], :path => '', :as => '' do
    # Omniauth routes
    get 'callback', :path => 'auth/:provider/callback'
    post 'callback', :path => 'auth/:provider/callback'
    get 'failure', :path => 'auth/failure'

    get 'login', :to => :new
    match 'logout', :to => :destroy,
                    :via => OpenStax::Accounts.configuration.logout_via
  end

  if OpenStax::Accounts.configuration.enable_stubbing?
    namespace :dev do
      resources :accounts, :only => [:index] do
        post 'index', :on => :collection
        post 'become', :on => :member
      end
    end
  end

end
