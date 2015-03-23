module OpenStax
  module Accounts
    class Api

      DEFAULT_API_VERSION = :v1

      # Executes an OpenStax Accounts API request,
      # using the given HTTP method, API path and request options.
      # Any options accepted by OAuth2 requests can be used, such as
      # :params, :body, :headers, etc, plus the :access_token option, which can
      # be used to manually specify an OAuth access token.
      # On failure, it can throw Faraday::ConnectionFailed for connection errors
      # or OAuth2::Error if Accounts returns an HTTP 400 error,
      # such as 422 Unprocessable Entity.
      # On success, returns an OAuth2::Response object.
      def self.request(http_method, path, options = {})
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

        accounts_url = OpenStax::Accounts.configuration.openstax_accounts_url
        url = URI.join(accounts_url, 'api/', path)

        token.request(http_method, url, options)
      end

      # Performs an account search in the Accounts server.
      # Results are limited to 10 accounts maximum.
      # Takes a query parameter and an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.search_accounts(query, version = DEFAULT_API_VERSION)
        options = {:params => {:q => query},
                   :api_version => version}
        request(:get, 'users', options)
      end

      # Updates a user account in the Accounts server.
      # The account is determined by the OAuth access token.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.update_account(account, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version,
                   :body => account.attributes.slice('username', 'first_name',
                              'last_name', 'full_name', 'title').to_json}
        request(:put, 'user', options)
      end

      # Performs an account search in the Accounts server.
      # Results are limited to accounts that have used the current app.
      # Takes a query parameter and an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.search_application_accounts(query, version = DEFAULT_API_VERSION)
        options = {:params => {:q => query},
                   :api_version => version}
        request(:get, 'application_users', options)
      end

      # Retrieves information about accounts that have been
      # recently updated.
      # Results are limited to accounts that have used the current app.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.get_application_account_updates(version = DEFAULT_API_VERSION)
        options = {:api_version => version}
        request(:get, 'application_users/updates', options)
      end

      # Marks account updates as "read".
      # The application_users parameter is an array of hashes.
      # Each hash has 2 required fields: 'id', which should contain the
      # application_user's id, and 'read_updates', which should contain
      # the last received value of unread_updates for that application_user.
      # Can only be called for application_users that belong to the current app.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.mark_account_updates_as_read(application_users, version = DEFAULT_API_VERSION)
        options = {:api_version => version,
                   :body => application_users.to_json}
        request(:put, 'application_users/updated', options)
      end

      # Retrieves information about groups that have been
      # recently updated.
      # Results are limited to groups that users of the current app have access to.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.get_application_group_updates(version = DEFAULT_API_VERSION)
        options = {:api_version => version}
        request(:get, 'application_groups/updates', options)
      end

      # Marks group updates as "read".
      # The application_groups parameter is an array of hashes.
      # Each hash has 2 required fields: 'id', which should contain the
      # application_group's id, and 'read_updates', which should contain
      # the last received value of unread_updates for that application_group.
      # Can only be called for application_groups that belong to the current app.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.mark_group_updates_as_read(application_groups, version = DEFAULT_API_VERSION)
        options = {:api_version => version,
                   :body => application_groups.to_json}
        request(:put, 'application_groups/updated', options)
      end

      # Creates a group in the Accounts server.
      # The given account will be the owner of the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group(account, group, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version,
                   :body => group.attributes.slice('name', 'is_public').to_json}
        response = ActiveSupport::JSON.decode(
          request(:post, 'groups', options).body
        )
        group.openstax_uid = response['id']
        response
      end

      # Updates a group in the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.update_group(account, group, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version,
                   :body => group.attributes.slice('name', 'is_public').to_json}
        request(:put, "groups/#{group.openstax_uid}", options)
      end

      # Deletes a group from the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group(account, group, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(:delete, "groups/#{group.openstax_uid}", options)
      end

      # Creates a group_member in the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group_member(account, group_member, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(
          :post,
          "groups/#{group_member.group_id}/members/#{group_member.user_id}",
          options
        )
      end

      # Deletes a group_member from the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group_member(account, group_member, version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(
          :delete,
          "groups/#{group_member.group_id}/members/#{group_member.user_id}",
          options
        )
      end

      # Creates a group_owner in the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group_owner(account, group_owner,
                                  version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(
          :post,
          "groups/#{group_owner.group_id}/owners/#{group_owner.user_id}",
          options
        )
      end

      # Deletes a group_owner from the Accounts server.
      # The given account must own the group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group_owner(account, group_owner,
                                   version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(
          :delete,
          "groups/#{group_owner.group_id}/owners/#{group_owner.user_id}",
          options
        )
      end

      # Creates a group_nesting in the Accounts server.
      # The given account must own both groups.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group_nesting(account, group_nesting,
                                    version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(
          :post,
          "groups/#{group_nesting.container_group_id}/nestings/#{
                    group_nesting.member_group_id}",
                 options)
      end

      # Deletes a group_nesting from the Accounts server.
      # The given account must own either group.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group_nesting(account, group_nesting,
                                     version = DEFAULT_API_VERSION)
        options = {:access_token => account.access_token,
                   :api_version => version}
        request(
          :delete,
          "groups/#{group_nesting.container_group_id}/nestings/#{
                    group_nesting.member_group_id}",
          options
        )
      end

      # Creates a temporary user in Accounts.
      # Also takes an optional API version parameter.
      # API version currently defaults to :v1 (may change in the future).
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_temp_account(attributes, version = DEFAULT_API_VERSION)
        options = { api_version: version,
                    body: attributes.to_json }

        request(:post, "user/find-or-create", options)
      end

      protected

      def self.client
        @client ||= OAuth2::Client.new(
          OpenStax::Accounts.configuration.openstax_application_id,
          OpenStax::Accounts.configuration.openstax_application_secret,
          :site => OpenStax::Accounts.configuration.openstax_accounts_url
        )
      end

    end
  end
end
