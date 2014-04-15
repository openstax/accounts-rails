require 'omniauth'
require 'omniauth/strategies/openstax'
require 'lev'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

module OpenStax
  module Accounts
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Accounts

      config.generators do |g|
        g.test_framework :rspec, :view_specs => false, :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end

      SETUP_PROC = lambda do |env|
        env['omniauth.strategy'].options[:client_options][:site] = OpenStax::Accounts.configuration.openstax_accounts_url
      end

      # Doesn't work to put this omniauth code in an engine initializer, instead:
      # https://gist.github.com/pablomarti/5243118
      middleware.use ::OmniAuth::Builder do
        provider :openstax, 
                 OpenStax::Accounts.configuration.openstax_application_id,
                 OpenStax::Accounts.configuration.openstax_application_secret,
                 :setup => SETUP_PROC
      end
    end
  end
end
