module OpenStax
  module Accounts
    class SessionsController < OpenStax::Accounts::ApplicationController

      def new
        session[:return_to] ||= request.referrer
        redirect_to RouteHelper.get_path(:login)
      end

      def omniauth_authenticated
        handle_with(SessionsOmniauthAuthenticated,
                    success: lambda {
                      sign_in(@handler_result.outputs[:accounts_user_to_sign_in])
                      # referrer is in Accounts, so don't include it
                      redirect_to return_url
                    },
                    failure: lambda {
                      failure
                    })
      end

      def destroy
        sign_out!

        # If we're using the Accounts server, need to sign out of it so can't 
        # log back in automagically
        redirect_to OpenStax::Accounts.configuration.enable_stubbing? ?
                      return_url :
                      OpenStax::Utilities.generate_url(
                        OpenStax::Accounts.configuration.openstax_accounts_url + "/logout",
                        return_to: return_url
                      )
      end

      def failure
        redirect_to return_url, alert: "Authentication failed, please try again."
      end

    end
  end
end
