require 'capybara'

# Initializes a Capybara server running the Dummy app
CAPYBARA_SERVER = Capybara::Server.new(Rails.application).boot

OpenStax::Accounts.configure do |config|
  config.openstax_accounts_url = "http://localhost:#{CAPYBARA_SERVER.port}/"
  config.openstax_application_id = 'secret'
  config.openstax_application_secret = 'secret'
  config.account_user_mapper = User
  config.logout_via = :delete
  config.min_search_characters = 3
  config.max_search_items = 10
  config.sso_secret_key = '1234567890abcd'
end
