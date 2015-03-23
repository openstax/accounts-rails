require 'oauth2'
require 'omniauth'
require 'openstax_utilities'
require 'uri'
require 'omniauth/strategies/openstax'
require 'openstax/accounts/api'
require 'openstax/accounts/configuration'
require 'openstax/accounts/current_user_manager'
require 'openstax/accounts/default_account_user_mapper'
require 'openstax/accounts/engine'

module OpenStax
  module Accounts

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

    end

  end
end
