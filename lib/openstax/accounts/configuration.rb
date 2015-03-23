module OpenStax
  module Accounts
    class Configuration
      # openstax_accounts_url
      # Base URL for OpenStax Accounts
      attr_reader :openstax_accounts_url

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

      def openstax_accounts_url=(url)
        url.gsub!(/https|http/,'https') if !(url =~ /localhost/)
        url = url + "/" if url[url.size-1] != '/'
        @openstax_accounts_url = url
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
        super
      end

      def enable_stubbing?
        !Rails.env.production? && enable_stubbing
      end
    end
  end
end
