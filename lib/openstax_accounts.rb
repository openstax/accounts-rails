require 'openstax/accounts/version'
require 'openstax/accounts/engine'
require 'openstax/accounts/route_helper'
require 'openstax/accounts/action_list'
require 'openstax/accounts/user_provider'
require 'openstax/accounts/current_user_manager'

require 'openstax_utilities'
require 'uri'
require 'oauth2'

module OpenStax
  module Accounts

    class << self

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
      # Set enable_stubbing to true iff you want this engine to fake all 
      #   interaction with the accounts site.
      #
      
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      class Configuration
        attr_accessor :openstax_application_id
        attr_accessor :openstax_application_secret
        attr_accessor :enable_stubbing
        attr_reader :openstax_accounts_url
        attr_accessor :logout_via
        attr_accessor :default_errors_partial
        attr_accessor :default_errors_html_id
        attr_accessor :default_errors_added_trigger
        attr_accessor :security_transgression_exception

        # See the "user_provider" discussion in the README 
        attr_accessor :user_provider

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
          @user_provider = OpenStax::Accounts::UserProvider
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
          options[:headers].merge!({ 'Accept' => "application/vnd.accounts.openstax.#{version.to_s}" })
        end

        token_string = options.delete(:access_token)
        token = token_string.blank? ? client.client_credentials.get_token :
                OAuth2::AccessToken.new(client, token_string)

        api_url = URI.join(configuration.openstax_accounts_url, 'api/', url)

        token.request(http_method, api_url, options)
      end

      # Creates an ApplicationUser in Accounts for this app and the given
      # OpenStax::Accounts::User.
      # Also takes an optional API version parameter. Defaults to :v1.
      # On failure, throws an Exception, just like api_call.
      # On success, returns an OAuth2::Response object.
      def create_application_user(user, version = nil)
        options = {:access_token => user.access_token,
                   :api_version => (version.nil? ? :v1 : version)}
        api_call(:post, 'application_users', options)
      end

    protected

      def client
        @client ||= OAuth2::Client.new(
                      configuration.openstax_application_id,
                      configuration.openstax_application_secret,
                      :site => configuration.openstax_accounts_url
                    )
      end

    end

  end
end
