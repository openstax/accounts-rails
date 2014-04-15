Rails.application.routes.draw do
  mount OpenStax::Accounts::Engine => "/accounts"

  namespace :api do
    post "dummy", :to => "dummy#dummy"

    resource :application_users, :only => :create
  end

  root :to => "application#index"
end
