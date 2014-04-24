module OpenStax
  module Accounts
    module Dev
      class UsersController < Openstax::Accounts::Dev::BaseController

        def login; end

        def search
          handle_with(UsersSearch,
                      complete: lambda { render 'search' })
        end

        def become
          @user = User.find(params[:id])
          sign_in(@user)
          redirect_to return_url
        end

      end
    end
  end
end
