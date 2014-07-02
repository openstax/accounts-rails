module OpenStax
  module Accounts
    module Dev
      class AccountsController < OpenStax::Accounts::Dev::BaseController

        def index
          handle_with(AccountsIndex)
        end

        def become
          @account = Account.find(params[:id])
          sign_in(@account)
          redirect_back
        end

      end
    end
  end
end
