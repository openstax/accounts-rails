module OpenStax
  module Accounts
    class SessionsController < OpenStax::Accounts::ApplicationController

      def new
        if OpenStax::Accounts.configuration.enable_stubbing?
          redirect_to dev_accounts_path
        else
          store_fallback key: :accounts_return_to, strategies: [:session]
          redirect_to openstax_login_path
        end
      end

      def callback
        handle_with(
          SessionsCallback,
            success: lambda {
              sign_in(@handler_result.outputs[:account])
              redirect_back key: :accounts_return_to, strategies: [:session]
            },
            failure: lambda {
              failure
            })
      end

      def destroy
        sign_out!

        # If we're using the Accounts server, need to sign out of it so can't 
        # log back in automagically
        if OpenStax::Accounts.configuration.enable_stubbing?
          redirect_to(:back)
        else
          redirect_to(
            OpenStax::Utilities.generate_url(
              OpenStax::Accounts.configuration.openstax_accounts_url, "logout"
            )
          )
        end
      end

      def failure
        redirect_back key: :accounts_return_to,
                      alert: "Authentication failed, please try again."
      end

    end
  end
end
