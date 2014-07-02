OpenStax::Accounts::Engine.routes.draw do

  # Redirect here if we don't know what to do (theoretically should not happen)
  root :to => 'sessions#new'

  # Shortcut to OmniAuth route that redirects to the Accounts server
  # This is provided by OmniAuth and is not in the SessionsController
  get '/auth/openstax', :as => 'openstax_login'

  # OmniAuth local routes (SessionsController)
  resource :session, :only => [], :path => '', :as => '' do
    get 'callback', :path => 'auth/:provider/callback' # Authentication success
    get 'failure', :path => 'auth/failure' # Authentication failure

    get 'login', :to => :new # Redirects to /auth/openstax or stub
    match 'logout', :to => :destroy, # Redirects to logout path or stub
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
