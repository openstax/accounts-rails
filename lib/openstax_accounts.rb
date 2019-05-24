require 'oauth2'
require 'omniauth'
require 'openstax_utilities'
require 'uri'
require 'omniauth/strategies/openstax'
require_relative 'openstax/accounts/api'
require_relative 'openstax/accounts/sso'
require_relative 'openstax/accounts/configuration'
require_relative 'openstax/accounts/current_user_manager'
require_relative 'openstax/accounts/default_account_user_mapper'
require_relative 'openstax/accounts/engine'

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
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

    end
  end
end
