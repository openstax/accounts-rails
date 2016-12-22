module OpenStax
  module Accounts
    module ActionController
      module Base

        def self.included(base)
          base.helper_method :current_user, :signed_in?, :openstax_accounts_login_path
        end

        # Returns the current user
        def current_user
          current_user_manager.current_user
        end

        # Returns the current account
        def current_account
          current_user_manager.current_account
        end

        # Returns true iff there is a user signed in
        def signed_in?
          current_user_manager.signed_in?
        end

        # Signs in the given account or user
        def sign_in(user)
          current_user_manager.sign_in(user)
        end

        # Signs out the current account and user
        def sign_out!
          current_user_manager.sign_out!
        end

        protected

        def current_user_manager
          @current_user_manager ||= \
            OpenStax::Accounts::CurrentUserManager.new(request, session, cookies)
        end

        def login_params
          @login_params ||= {}
        end

        def openstax_accounts_login_path
          openstax_accounts.login_path(login_params)
        end

        def authenticate_user!
          account = current_account

          return if account && !account.is_anonymous?

          store_url key: :accounts_return_to, strategies: [:session]

          respond_to do |format|
            format.json { head(:forbidden) }
            format.any  {
              redirect_to openstax_accounts_login_path
            }
          end
        end

      end
    end
  end
end

::ActionController::Base.send :include, OpenStax::Accounts::ActionController::Base
