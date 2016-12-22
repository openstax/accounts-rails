ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

require 'action_interceptor'
require 'doorkeeper'
require 'keyword_search'
require 'lev'
require 'representable'
require 'representable/json/collection'
require 'roar'
require 'roar/decorator'
require 'roar/json'
require 'squeel'
require 'openstax/accounts/action_controller/base'
require 'openstax/accounts/has_many_through_groups/active_record/base'

module OpenStax
  module Accounts
    class Engine < ::Rails::Engine
      isolate_namespace OpenStax::Accounts

      initializer "openstax_accounts.factories",
        :after => "factory_girl.set_factory_paths" do
        FactoryGirl.definition_file_paths << File.join(root, 'spec', 'factories') if defined?(FactoryGirl)
      end

      config.generators do |g|
        g.test_framework :rspec, :view_specs => false, :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end

      SETUP_PROC = lambda do |env|
        # Useful link for how to pass params through omniauth/doorkeeper:
        #  https://github.com/doorkeeper-gem/doorkeeper/wiki/Passing-parameters-from-a-devise-client-to-doorkeeper-(like-locale)

        # request spec `env` doesn't honor "rack.request.query_hash" shortcut, so we fallback
        # to manually parsing the query string.  Also make sure to use an extra fallback of an
        # empty hash because setting the authorize_params to nil upsets Omniauth.
        query_hash = env["rack.request.query_hash"] ||
                     Rack::Utils.parse_nested_query(env["QUERY_STRING"]) ||
                     {}
        env['omniauth.strategy'].options.authorize_params = query_hash

        env['omniauth.strategy'].options[:client_options][:site] =
          OpenStax::Accounts.configuration.openstax_accounts_url
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
