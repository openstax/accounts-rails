module OpenStax
  module Accounts
    class SessionsController < OpenStax::Accounts::ApplicationController

      def new
        if configuration.is_return_to_url_approved?(params[:return_to])
          store_url url: params[:return_to], key: :accounts_return_to, strategies: [:session]
        end
        store_fallback key: :accounts_return_to, strategies: [:session]

        if configuration.enable_stubbing?
          redirect_to dev_accounts_path
        else
          forwardable_params =
            params.permit(*configuration.forwardable_login_param_keys.map(&:to_s)).to_h
          redirect_to openstax_login_path(forwardable_params)
        end
      end

      def callback
        handle_with(
          SessionsCallback,
          success: -> do
            sign_in(@handler_result.outputs[:account])
            redirect_back key: :accounts_return_to, strategies: [:session]
          end,
          failure: -> { failure }
        )
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
        redirect_back key: :accounts_return_to, alert: "Authentication failed, please try again."
      end

      def profile
        # TODO: stub profile if stubbing is enabled
        redirect_to URI.join(configuration.openstax_accounts_url, "/profile").to_s
      end

    end
  end
end
