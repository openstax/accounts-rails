OpenStax::Accounts::Engine.routes.draw do

  # Redirect here if we don't know what to do (theoretically should not happen)
  root :to => 'sessions#new'

  # Shortcut to OmniAuth route that redirects to the Accounts server
  # This is provided by OmniAuth and is not in the SessionsController
  get '/auth/openstax', :as => 'openstax_login'

  # User profile route
  if OpenStax::Accounts.configuration.enable_stubbing?
    namespace :dev do
      resources :accounts, :only => [:index, :create] do
        post 'become', :on => :member
        get 'search', :on => :collection
      end
    end
  end

  # OmniAuth local routes (SessionsController)
  scope module: 'sessions' do
    get 'callback', :path => 'auth/:provider/callback' # Authentication success
    get 'failure', :path => 'auth/failure' # Authentication failure

    get 'login', :action => :new # Redirects to /auth/openstax or stub
    get 'signed_login', :action => :new, :sign => 1 # signs query parameters

    match 'logout', :action => :destroy, # Redirects to logout path or stub
                    :via => OpenStax::Accounts.configuration.logout_via
    get 'profile', :action => :profile # Redirects to profile path or stub
  end

end
