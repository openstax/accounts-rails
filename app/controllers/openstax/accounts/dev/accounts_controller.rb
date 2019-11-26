module OpenStax
  module Accounts
    module Dev
      class AccountsController < OpenStax::Accounts::Dev::BaseController
        # Allow accessing from inside an iframe
        before_action :allow_iframe_access, only: :index

        def index
          handle_with AccountsSearch
        end

        def create
          handle_with(
            AccountsCreate,
            success: -> do
              username = @handler_result.outputs.account.username
              flash.notice = "Account with username \"#{username}\" created."
              redirect_to dev_accounts_path(search: { query: username })
            end,
            failure: -> do
              flash.alert = @handler_result.errors.first.translate
              redirect_to dev_accounts_path(search: { query: params.dig(:create, :username) })
            end
          )
        end

        def become
          @account = Account.find(params[:id])
          sign_in @account
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
