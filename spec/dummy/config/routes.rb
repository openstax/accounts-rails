Rails.application.routes.draw do
  mount OpenStax::Connect::Engine => "/connect"

  namespace :api do
    post "dummy", :to => "dummy#dummy"

    resource :application_users, :only => :create
  end

  root :to => "application#index"
end
