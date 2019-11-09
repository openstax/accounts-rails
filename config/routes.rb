OpenStax::Accounts::Engine.routes.draw do
  # Redirect here if we don't know what to do (theoretically should not happen)
  root to: 'sessions#new'

  # Shortcut to OmniAuth route that redirects to the Accounts server
  # This is provided by OmniAuth and is not in the SessionsController
  get '/auth/openstax', as: 'openstax_login'

  # User profile route
  namespace :dev do
    resources :accounts, only: [:index, :create] do
      post 'become', on: :member
      get 'search', on: :collection
    end
  end if OpenStax::Accounts.configuration.enable_stubbing?

  # OmniAuth local routes (SessionsController)
  scope module: 'sessions' do
    get 'auth/:provider/callback', action: :callback, as: :callback # Authentication success
    get 'auth/failure', action: :failure, as: :failure              # Authentication failure

    get 'login', action: :new # Redirects to /auth/openstax or stub
    match 'logout', action: :destroy, # Redirects to logout path or stub
                    via: OpenStax::Accounts.configuration.logout_via
    get 'profile', action: :profile # Redirects to profile path or stub
  end
end
