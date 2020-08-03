module OpenStax
  module Accounts
    class Configuration
      # openstax_accounts_url
      # Base URL for OpenStax Accounts
      attr_reader :openstax_accounts_url

      def openstax_accounts_url=(url)
        url.gsub!(/https|http/,'https') if !(url =~ /localhost/)
        url = url + "/" if url[url.size-1] != '/'
        @openstax_accounts_url = url
      end

      # openstax_application_id
      # OAuth client_id received from OpenStax Accounts
      attr_accessor :openstax_application_id

      # openstax_application_secret
      # OAuth client_secret received from OpenStax Accounts
      attr_accessor :openstax_application_secret

      # enable_stubbing
      # Set to true if you want this engine to fake all
      # interaction with the accounts site.
      attr_accessor :enable_stubbing

      # logout_via
      # HTTP method to accept for logout requests
      attr_accessor :logout_via

      attr_accessor :default_errors_partial
      attr_accessor :default_errors_html_id
      attr_accessor :default_errors_added_trigger

      # security_transgression_exception
      # Class to be used for security transgression exceptions
      attr_accessor :security_transgression_exception

      # account_user_mapper
      # This class teaches the gem how to convert between accounts and users
      # See the "account_user_mapper" discussion in the README
      attr_accessor :account_user_mapper

      # min_search_characters
      # The minimum number of characters that can be used
      # as a query in a call to the AccountsSearch handler
      # If less are used, the handler will return an error instead
      attr_accessor :min_search_characters

      # max_search_items
      # The maximum number of accounts that can be returned
      # in a call to the AccountsSearch handler
      # If more would be returned, the result will be empty instead
      attr_accessor :max_search_items

      # logout_handler
      # Handles logging out and redirecting user when they've requested logout
      # if specified, the logout_redirect_url has no effect
      attr_accessor :logout_handler

      # logout_redirect_url
      # A URL to redirect to after the app logs out, can be a string or a Proc.
      # If a Proc (or lambda), it will be called with the logout request.
      #
      # Only used if the logout_handler above is not specified
      # If this field is nil or if the Proc returns nil, the logout will redirect
      # to the default Accounts logout URL.
      attr_writer :logout_redirect_url

      # forwardable_login_params
      # Which params are forwarded on the accounts login path
      attr_accessor :forwardable_login_params

      # max_user_updates_per_request
      # When the user profile sync operation is called, this parameter will limit
      # the number of returned profile updates from Accounts; helpful when all
      # accounts have been marked as updated on Accounts so that we don't get
      # overloaded.
      attr_accessor :max_user_updates_per_request

      # sso_secret_key
      # The secret key used to decode the SSO cookie
      # will be used to decryp the shared user session set by accounts
      # when a user logs in, and cleared when they logout
      attr_accessor :sso_secret_key

      # sso_secret_salt
      # The salt that should be used to decypt the SSO session. Defaults to 'cookie'
      attr_accessor :sso_secret_salt

      # sso_cookie_name
      # The name of the cookie that stores the SSO session. Defaults to 'ox'
      attr_accessor :sso_cookie_name

      def logout_redirect_url(request)
        (@logout_redirect_url.is_a?(Proc) ?
           @logout_redirect_url.call(request) :
           @logout_redirect_url) ||
        default_logout_redirect_url
      end

      def default_logout_redirect_url
        URI.join(openstax_accounts_url, "logout").to_s
      end

      attr_writer :return_to_url_approver

      def is_return_to_url_approved?(return_to_url)
        return_to_url &&
        @return_to_url_approver.is_a?(Proc) &&
        @return_to_url_approver.call(return_to_url)
      end

      def initialize
        @openstax_application_id = 'SET ME!'
        @openstax_application_secret = 'SET ME!'
        @openstax_accounts_url = 'https://accounts.openstax.org/'
        @enable_stubbing = true
        @logout_via = :get
        @default_errors_partial = 'openstax/accounts/shared/attention'
        @default_errors_html_id = 'openstax-accounts-attention'
        @default_errors_added_trigger = 'openstax-accounts-errors-added'
        @security_transgression_exception = SecurityTransgression
        @account_user_mapper = OpenStax::Accounts::DefaultAccountUserMapper
        @min_search_characters = 3
        @max_search_items = 10
        @logout_handler = nil
        @logout_redirect_url = nil
        @return_to_url_approver = nil
        @forwardable_login_params = [
          :signup_at,
          :go,
          sp: {} # "signed payload"; "sp" to keep nested parameter names short.
        ]
        @max_user_updates_per_request = 250
        @sso_cookie_name = 'ox'
        @sso_secret_salt = 'cookie'
        super
      end

      def enable_stubbing?
        !Rails.env.production? && enable_stubbing
      end
    end
  end
end
