module OpenStax
  module Accounts
    class CurrentUserManager

      def initialize(request, session, cookies)
        @request = request
        @session = session
        @cookies = cookies
      end

      # Returns the current account
      def current_account
        load_session
        @current_account
      end

      # Returns the current user
      def current_user
        load_session
        @current_user
      end

      # Signs in the given user or account
      def sign_in!(user)
        user.is_a?(Account) ?
          self.current_account = user :
          self.current_user = user
      end

      alias_method :sign_in, :sign_in!

      # Signs out the currently signed in user
      def sign_out!
        self.current_account = AnonymousAccount.instance
      end

      alias_method :sign_out, :sign_out!

      # Returns true iff there is a user signed in
      def signed_in?
        !current_account.is_anonymous?
      end

      protected

      # Sets the session state based on the given account
      def set_session(account)
        if account.is_anonymous?
          @session[:account_id] = nil
          @cookies.delete(:secure_account_id)
        else
          @session[:account_id] = account.id
          @cookies.encrypted[:secure_account_id] = { secure: true,
            httponly: true, value: "secure#{account.id}" }
        end
      end

      # If not already loaded, sets the current user and current account
      # based on the session state
      def load_session
        return unless @current_account.nil?

        # first try to use SSO authentication
        sso = OpenStax::Accounts::Sso.decrypt @request
        if sso.present?
          load_session_from_sso(sso)
          return
        end

        # If no SSO was found, fall back to using our own session
        # Sign the user out to reset the session if the request is SSL
        # and the signed secure ID doesn't match the unsecure ID
        # http://railscasts.com/episodes/356-dangers-of-session-hijacking
        if @request.ssl? && \
          @cookies.encrypted[:secure_account_id] != "secure#{@session[:account_id]}"
          sign_out!
          return
        end

        # If there is a session account_id, load up that account,
        # otherwise set the anonymous account.
        if @session[:account_id]
          @current_account = Account.where(id: @session[:account_id]).first

          # It could happen (normally in development) that there is a session
          # account_id that doesn't map to an Account in the db.
          # In such a case, sign_out! to reset the state
          if @current_account.nil?
            sign_out!
            return
          end
        else
          @current_account = AnonymousAccount.instance
        end

        # Bring the user inline with the account
        @current_user = account_user_mapper.account_to_user(@current_account)
      end

      def load_session_from_sso(sso)
        user_attrs = sso['user']
        account = FindOrCreateFromSso[user_attrs]
        if account.present?
          self.current_user = account_user_mapper.account_to_user(account)
          set_session account
          @session[:account_id] = account.id
        else
          sign_out!
        end
      end

      # Sets the current account, updates the session and loads it
      def current_account=(account)
        set_session(account)
        @current_user = account_user_mapper.account_to_user(account)
        @current_account = account
      end

      # Sets (signs in) the provided user, as above
      def current_user=(user)
        @current_account = account_user_mapper.user_to_account(user)
        set_session(@current_account)
        @current_user = user
      end

      def account_user_mapper
        OpenStax::Accounts.configuration.account_user_mapper
      end

    end
  end
end
