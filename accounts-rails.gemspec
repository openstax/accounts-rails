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

  s.files = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.1"
  s.add_dependency "omniauth", ">= 1.1"
  s.add_dependency "omniauth-oauth2", ">= 1.1"
  s.add_dependency "oauth2", ">= 0.5.0"
  s.add_dependency "squeel", ">= 0.5.0"
  s.add_dependency "representable", ">= 2.0"
  s.add_dependency "roar", ">= 1.0"
  s.add_dependency "lev", ">= 2.2.1"
  s.add_dependency "keyword_search", ">= 1.0.0"
  s.add_dependency "openstax_utilities", ">= 4.1.0"
  s.add_dependency "openstax_api", ">= 3.1.0"
  s.add_dependency "action_interceptor", ">= 1.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "quiet_assets"
  s.add_development_dependency "thin"
  s.add_development_dependency "responders"
end
