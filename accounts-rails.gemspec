$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "openstax/accounts/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openstax_accounts"
  s.version     = OpenStax::Accounts::VERSION
  s.authors     = ["JP Slavinsky"]
  s.email       = ["jps@kindlinglabs.com"]
  s.homepage    = "http://github.com/openstax/accounts-rails"
  s.summary     = "Rails common code and bindings for the 'accounts' API"
  s.description = "This gem allows Rails apps to easily access the API's and login infrastructure of OpenStax Accounts."

  s.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*"] +
            ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  s.add_dependency "omniauth"
  s.add_dependency "omniauth-oauth2"
  s.add_dependency "oauth2"
  s.add_dependency "representable"
  s.add_dependency "roar"
  s.add_dependency "lev"
  s.add_dependency "keyword_search"
  s.add_dependency "openstax_utilities"
  s.add_dependency "openstax_api"
  s.add_dependency "action_interceptor"
  s.add_dependency "pg"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "puma"
  s.add_development_dependency "responders"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
end
