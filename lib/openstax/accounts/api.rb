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
      # Results are limited to accounts that have used the current app, and
      # limited in quantity per call by a configuration parameter.
      # Takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.get_application_account_updates(options = {})
        limit = OpenStax::Accounts.configuration.max_user_updates_per_request
        request(
          :get, "application_users/updates#{ '?limit=' + limit.to_s if !limit.blank? }", options
        )
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
        request(:put, 'application_users/updated', options.merge(body: application_users.to_json))
      end

      # Finds an account matching the provided attributes or creates a new
      # account.  Also takes an options hash.
      # On failure, throws an Exception, just like the request method.
      # On success, returns an OAuth2::Response object.
      def self.find_or_create_account(attributes, options = {})
        request(:post, "user/find-or-create", options.merge(body: attributes.to_json))
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
