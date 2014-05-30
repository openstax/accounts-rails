module OpenStax
  module Accounts
    module Dev
      class UsersController < OpenStax::Accounts::Dev::BaseController

        def index
          handle_with(UsersIndex,
                      complete: lambda { render 'index' })
        end

        def login; end

        def become
          @user = User.find(params[:id])
          sign_in(@user)
          redirect_to return_url
        end

      end
    end
  end
end
