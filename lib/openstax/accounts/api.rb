module OpenStax
  module Accounts
    module Api

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
        version = options.delete(:api_version) || DEFAULT_API_VERSION
        unless version.blank?
          options[:headers] ||= {}
          options[:headers].merge!({
            'Accept' => "application/vnd.accounts.openstax.#{version.to_s}",
            'Content-Type' => 'application/json'
          })
        end

        token_string = options.delete(:access_token)
        token = token_string.blank? ? client.client_credentials.get_token :
                  OAuth2::AccessToken.new(client, token_string)

        accounts_url = OpenStax::Accounts.configuration.openstax_accounts_url
        url = URI.join(accounts_url, 'api/', path)

        token.request(http_method, url, options)
      end

      # Performs an API request using the given account's access token
      def self.request_for_account(account, http_method, path, options = {})
        request(http_method, path,
                options.merge(access_token: account.access_token))
      end

      # Performs an account search in the Accounts server.
      # Results are limited to 10 accounts maximum.
      # Takes a query parameter and an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.search_accounts(query, options = {})
        request(:get, 'users', options.merge(params: {q: query}))
      end

      # Updates a user account in the Accounts server.
      # The account is determined by the OAuth access token.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.update_account(account, options = {})
        request_for_account(
          account, :put, 'user', options.merge(
            body: account.attributes.slice('username', 'first_name',
                                           'last_name', 'full_name',
                                           'title').to_json
          )
        )
      end

      # Performs an account search in the Accounts server.
      # Results are limited to accounts that have used the current app.
      # Takes a query parameter and an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.search_application_accounts(query, options = {})
        request(:get, 'application_users', options.merge(params: {q: query}))
      end

      # Retrieves information about accounts that have been
      # recently updated.
      # Results are limited to accounts that have used the current app.
      # Takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.get_application_account_updates(options = {})
        request(:get, 'application_users/updates', options)
      end

      # Marks account updates as "read".
      # The application_users parameter is an array of hashes.
      # Each hash has 2 required fields: 'id', which should contain the
      # application_user's id, and 'read_updates', which should contain
      # the last received value of unread_updates for that application_user.
      # Can only be called for application_users that belong to the current app.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.mark_account_updates_as_read(application_users, options = {})
        request(:put, 'application_users/updated', options.merge(
          body: application_users.to_json
        ))
      end

      # Retrieves information about groups that have been
      # recently updated.
      # Results are limited to groups that users of the current app
      # have access to.
      # Takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.get_application_group_updates(options = {})
        request(:get, 'application_groups/updates', options)
      end

      # Marks group updates as "read".
      # The application_groups parameter is an array of hashes.
      # Each hash has 2 required fields: 'id', which should contain the
      # application_group's id, and 'read_updates', which should contain
      # the last received value of unread_updates for that application_group.
      # Can only be called for application_groups that belong to the current app.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.mark_group_updates_as_read(application_groups, options = {})
        request(:put, 'application_groups/updated', options.merge(
          body: application_groups.to_json
        ))
      end

      # Creates a group in the Accounts server.
      # The given account will be the owner of the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns a hash containing the group attributes
      def self.create_group(account, group, options = {})
        response = ActiveSupport::JSON.decode(
          request_for_account(account, :post, 'groups', options.merge(
            body: group.attributes.slice('name', 'is_public').to_json
          )).body
        )
        group.openstax_uid = response['id']
        response
      end

      # Updates a group in the Accounts server.
      # The given account must own the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.update_group(account, group, options = {})
        request_for_account(account, :put, "groups/#{group.openstax_uid}",
          options.merge(
            body: group.attributes.slice('name', 'is_public').to_json
          )
        )
      end

      # Deletes a group from the Accounts server.
      # The given account must own the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group(account, group, options = {})
        request_for_account(account, :delete,
                            "groups/#{group.openstax_uid}", options)
      end

      # Creates a group_member in the Accounts server.
      # The given account must own the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group_member(account, group_member, options = {})
        request_for_account(
          account,
          :post,
          "groups/#{group_member.group_id}/members/#{group_member.user_id}",
          options
        )
      end

      # Deletes a group_member from the Accounts server.
      # The given account must own the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group_member(account, group_member, options = {})
        request_for_account(
          account,
          :delete,
          "groups/#{group_member.group_id}/members/#{group_member.user_id}",
          options
        )
      end

      # Creates a group_owner in the Accounts server.
      # The given account must own the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group_owner(account, group_owner, options = {})
        request_for_account(
          account,
          :post,
          "groups/#{group_owner.group_id}/owners/#{group_owner.user_id}",
          options
        )
      end

      # Deletes a group_owner from the Accounts server.
      # The given account must own the group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group_owner(account, group_owner, options = {})
        request_for_account(
          account,
          :delete,
          "groups/#{group_owner.group_id}/owners/#{group_owner.user_id}",
          options
        )
      end

      # Creates a group_nesting in the Accounts server.
      # The given account must own both groups.
      # Also takes an an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.create_group_nesting(account, group_nesting, options = {})
        request_for_account(
          account,
          :post,
          "groups/#{group_nesting.container_group_id}/nestings/#{
                    group_nesting.member_group_id}",
                 options)
      end

      # Deletes a group_nesting from the Accounts server.
      # The given account must own either group.
      # Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.destroy_group_nesting(account, group_nesting, options = {})
        request_for_account(
          account,
          :delete,
          "groups/#{group_nesting.container_group_id}/nestings/#{
                    group_nesting.member_group_id}",
          options
        )
      end

      # Finds an account matching the provided attributes or creates a new
      # account.  Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.find_or_create_account(attributes, options = {})
        request(:post, "user/find-or-create", options.merge(
          body: attributes.to_json
        ))
      end

      protected

      def self.client
        @client ||= OAuth2::Client.new(
          OpenStax::Accounts.configuration.openstax_application_id,
          OpenStax::Accounts.configuration.openstax_application_secret,
          site: OpenStax::Accounts.configuration.openstax_accounts_url
        )
      end

    end
  end
end
