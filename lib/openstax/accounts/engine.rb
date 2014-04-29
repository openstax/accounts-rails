require 'omniauth'
require 'omniauth/strategies/openstax'
require 'lev'
require 'roar/decorator'
require 'roar/representer/json'
require 'keyword_search'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

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
