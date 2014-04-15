AccountsExample::Application.routes.draw do

  mount OpenStax::Accounts::Engine, at: "/accounts"

  root :to => 'static_page#home'

end
