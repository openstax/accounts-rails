module OpenStax
  module Accounts
    module Dev
      class AccountsController < OpenStax::Accounts::Dev::BaseController
        # Allow accessing from inside an iframe
        before_filter :allow_iframe_access, only: [:index, :search]

        def index
        end

        def search
          handle_with(AccountsSearch)
        end

        def create
          handle_with(AccountsCreate,
                      complete: lambda { redirect_to dev_accounts_path })
        end

        def become
          @account = Account.find_by(openstax_uid: params[:id])
          sign_in(@account)
          redirect_back key: :accounts_return_to, strategies: [:session]
        end

        private

        def allow_iframe_access
          response.headers.except! 'X-Frame-Options'
        end

      end
    end
  end
end
