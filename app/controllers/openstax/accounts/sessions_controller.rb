module OpenStax
  module Accounts
    class SessionsController < OpenStax::Accounts::ApplicationController

      def new
        if configuration.enable_stubbing?
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
              sign_in(@handler_result.account)
              redirect_back key: :accounts_return_to, strategies: [:session]
            },
            failure: lambda {
              failure
            })
      end

      def destroy
        sign_out!

        # Unless we are stubbing, we redirect to a configurable URL, which is normally
        # (or at least eventually) the Accounts logout URL so that users can't sign back
        # in automagically.
        redirect_to configuration.enable_stubbing? ?
                    main_app.root_url :
                    configuration.logout_redirect_url(request)
      end

      def failure
        redirect_back key: :accounts_return_to,
                      alert: "Authentication failed, please try again."
      end

      def profile
        # TODO: stub profile if stubbing is enabled
        redirect_to URI.join(configuration.openstax_accounts_url, "/profile").to_s
      end

    end
  end
end
