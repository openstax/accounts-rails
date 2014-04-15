module OpenStax
  module Accounts
    module Dev
      class UsersController < OpenStax::Accounts::Dev::DevController
        
        def login; end

        def search
          handle_with(OpenStax::Accounts::Dev::UsersSearch,
                      complete: lambda { render 'search' })
        end

        def become
          sign_in(User.find(params[:user_id]))
          redirect_to return_url(true)
        end

      end
    end
  end
end