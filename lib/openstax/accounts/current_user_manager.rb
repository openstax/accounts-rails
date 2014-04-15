module OpenStax
  module Accounts
    class CurrentUserManager

      # References:
      #   http://railscasts.com/episodes/356-dangers-of-session-hijacking

      def initialize(request, session, cookies)
        @request = request
        @session = session
        @cookies = cookies
      end

      # Returns the current app user
      def current_user
        load_current_users
        @app_current_user
      end

      # Signs in the given user; the argument can be either an accounts user or
      # an app user
      def sign_in(user)
        user.is_a?(User) ?
          self.accounts_current_user = user :
          self.current_user = user
      end

      # Signs out the user
      def sign_out!
        sign_in(OpenStax::Accounts::User.anonymous)
      end

      # Returns true iff there is a user signed in
      def signed_in?
        !accounts_current_user.is_anonymous?
      end

      # Returns the current accounts user
      def accounts_current_user
        load_current_users
        @accounts_current_user
      end

    protected

      # If they are nil (unset), sets the current users based on the session state
      def load_current_users
        return if !@accounts_current_user.nil?

        if @request.ssl? && @cookies.signed[:secure_user_id] != "secure#{@session[:user_id]}"
          sign_out! # hijacked
        else
          # If there is a session user_id, load up that user, otherwise set the anonymous user.
         
          if @session[:user_id]
            @accounts_current_user = User.where(id: @session[:user_id]).first

            # It could happen (normally in development) that there is a session
            # user_id that doesn't map to a User in the db.
            # In such a case, sign_out! to reset the state
            if @accounts_current_user.nil?
              sign_out!
              return
            end
          else
            @accounts_current_user = User.anonymous
          end

          # Bring the app user inline with the accounts user
          @app_current_user = user_provider.accounts_user_to_app_user(@accounts_current_user)
        end
      end

      # Sets (signs in) the provided app user.
      def current_user=(user)
        self.accounts_current_user = user_provider.app_user_to_accounts_user(user)
        @app_current_user
      end

      # Sets the current accounts user, updates the app user, and also updates
      # the session and cookie state.
      def accounts_current_user=(user)
        @accounts_current_user = user || User.anonymous
        @app_current_user = user_provider.accounts_user_to_app_user(@accounts_current_user)

        if @accounts_current_user.is_anonymous?
          @session[:user_id] = nil
          @cookies.delete(:secure_user_id)
        else
          @session[:user_id] = @accounts_current_user.id
          @cookies.signed[:secure_user_id] = {secure: true, value: "secure#{@accounts_current_user.id}"}
        end

        @accounts_current_user
      end

      def user_provider
        OpenStax::Accounts.configuration.user_provider
      end

    end
  end
end