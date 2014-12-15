require 'openstax/accounts/version'
require 'openstax/accounts/engine'
require 'openstax/accounts/default_account_user_mapper'
require 'openstax/accounts/current_user_manager'
require 'openstax/accounts/has_many_through_groups'
require 'openstax_utilities'

require 'oauth2'
require 'uri'

module OpenStax
  module Accounts

    DEFAULT_API_VERSION = :v1

    class << self

      mattr_accessor :syncing

      ###########################################################################
      #
      # Configuration machinery.
      #
      # To configure OpenStax Accounts, put the following code in your
      # application's initialization logic
      # (eg. in the config/initializers in a Rails app)
      #
      #   OpenStax::Accounts.configure do |config|
      #     config.<parameter name> = <parameter value>
      #     ...
      #   end
      #
      
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

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

      # Executes an OpenStax Accounts API call, using the given HTTP method,
      # API url and request options.
      # Any options accepted by OAuth2 requests can be used, such as
      # :params, :body, :headers, etc, plus the :access_token option, which can
      # be used to manually specify an OAuth access token.
      # On failure, it can throw Faraday::ConnectionFailed for connection errors
      # or OAuth2::Error if Accounts returns an HTTP 400 error,
      # such as 422 Unprocessable Entity.
      # On success, returns an OAuth2::Response object.
      def api_call(http_method, url, options = {})
        version = options.delete(:api_version)
        unless version.blank?
          options[:headers] ||= {}
          options[:headers].merge!({
            'Accept' => "application/vnd.accounts.openstax.#{version.to_s}"
          })
        end

        token_string = options.delete(:access_token)
        token = token_string.blank? ? client.client_credentials.get_token :
                  OAuth2::AccessToken.new(client, token_string)

        api_url = URI.join(configuration.openstax_accounts_url, 'api/', url)

        token.request(http_method, api_url, options)
      end

      # Performs an account search in the Accounts server.
      # Results are limited to 10 accounts maximum.
      # Takes a query parameter and an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def search_accounts(query, version = DEFAULT_API_VERSION)
        options = {:params => {:q => query},
                   :api_version => version}
        api_call(:get, 'users', options)
      end

      # Updates a user account in the Accounts server.
      # The account is determined by the OAuth access token.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def update_account(account, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version,
                   :body => account.attributes.slice('username', 'first_name',
                              'last_name', 'full_name', 'title').to_json}
        api_call(:put, 'user', options)
      end

      # Performs an account search in the Accounts server.
      # Results are limited to accounts that have used the current app.
      # Takes a query parameter and an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def search_application_accounts(query, version = DEFAULT_API_VERSION)
        options = {:params => {:q => query},
                   :api_version => version}
        api_call(:get, 'application_users', options)
      end

      # Retrieves information about accounts that have been
      # recently updated.
      # Results are limited to accounts that have used the current app.
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def get_application_account_updates(version = DEFAULT_API_VERSION)
        options = {:api_version => version}
        api_call(:get, 'application_users/updates', options)
      end

      # Marks account updates as "read".
      # The application_users parameter is an array of hashes.
      # Each hash has 2 required fields: 'id', which should contain the
      # application_user's id, and 'read_updates', which should contain
      # the last received value of unread_updates for that application_user.
      # Can only be called for application_users that belong to the current app.
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def mark_account_updates_as_read(application_users, version = DEFAULT_API_VERSION)
        options = {:api_version => version,
                   :body => application_users.to_json}
        api_call(:put, 'application_users/updated', options)
      end

      # Retrieves information about groups that have been
      # recently updated.
      # Results are limited to groups that users of the current app have access to.
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def get_application_group_updates(version = DEFAULT_API_VERSION)
        options = {:api_version => version}
        api_call(:get, 'application_groups/updates', options)
      end

      # Marks group updates as "read".
      # The application_groups parameter is an array of hashes.
      # Each hash has 2 required fields: 'id', which should contain the
      # application_group's id, and 'read_updates', which should contain
      # the last received value of unread_updates for that application_group.
      # Can only be called for application_groups that belong to the current app.
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def mark_group_updates_as_read(application_groups, version = DEFAULT_API_VERSION)
        options = {:api_version => version,
                   :body => application_groups.to_json}
        api_call(:put, 'application_groups/updated', options)
      end

      # Creates a group in the Accounts server.
      # The given account will be the owner of the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def create_group(account, group, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version,
                   :body => group.attributes.slice('name', 'is_public').to_json}
        response = ActiveSupport::JSON.decode(api_call(
                     :post, 'groups', options).body)
        group.openstax_uid = response['id']
        response
      end

      # Updates a group in the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def update_group(account, group, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version,
                   :body => group.attributes.slice('name', 'is_public').to_json}
        api_call(:put, "groups/#{group.openstax_uid}", options)
      end

      # Deletes a group from the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def destroy_group(account, group, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:delete, "groups/#{group.openstax_uid}", options)
      end

      # Creates a group_member in the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def create_group_member(account, group_member, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:post,
                 "groups/#{group_member.group_id}/members/#{group_member.user_id}",
                 options)
      end

      # Deletes a group_member from the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def destroy_group_member(account, group_member, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:delete,
                 "groups/#{group_member.group_id}/members/#{group_member.user_id}",
                 options)
      end

      # Creates a group_owner in the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def create_group_owner(account, group_owner, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:post,
                 "groups/#{group_owner.group_id}/owners/#{group_owner.user_id}",
                 options)
      end

      # Deletes a group_owner from the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def destroy_group_owner(account, group_owner, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:delete,
                 "groups/#{group_owner.group_id}/owners/#{group_owner.user_id}",
                 options)
      end

      # Creates a group_nesting in the Accounts server.
      # The given account must own both groups.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def create_group_nesting(account, group_nesting, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:post,
                 "groups/#{group_nesting.container_group_id}/nestings/#{group_nesting.member_group_id}",
                 options)
      end

      # Deletes a group_nesting from the Accounts server.
      # The given account must own either group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def destroy_group_nesting(account, group_nesting, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        api_call(:delete,
                 "groups/#{group_nesting.container_group_id}/nestings/#{group_nesting.member_group_id}",
                 options)
      end

      protected

      def client
        @client ||= OAuth2::Client.new(configuration.openstax_application_id,
                      configuration.openstax_application_secret,
                      :site => configuration.openstax_accounts_url)
      end

    end

  end
end
