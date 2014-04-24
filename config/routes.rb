OpenStax::Accounts::Engine.routes.draw do
  get '/auth/openstax/callback', to: 'sessions#omniauth_authenticated' #omniauth route
  get '/auth/openstax', :as => 'openstax_login'

  get 'sessions/new', :as => 'login'
  # See https://github.com/plataformatec/devise/commit/f3385e96abf50e80d2ae282e1fb9bdad87a83d3c
  match 'sessions/destroy', :as => 'logout',
                            :via => OpenStax::Accounts.configuration.logout_via

  if OpenStax::Accounts.configuration.enable_stubbing?
    namespace :dev do
      resources :users, :only => [] do
        collection do
          get 'login'
          post 'search'
        end

        post 'become', :on => :member
      end
    end
  end
end

hh = OpenStax::Accounts::Engine.routes.url_helpers

OpenStax::Accounts::RouteHelper.register_path(:login, hh.openstax_login_path) { hh.login_dev_users_path }
