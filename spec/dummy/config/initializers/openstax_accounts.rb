require 'capybara'

# Initializes a Capybara server running the Dummy app
CAPYBARA_SERVER = Capybara::Server.new(Rails.application).boot

OpenStax::Accounts.configure do |config|
  config.openstax_accounts_url = "http://localhost:#{CAPYBARA_SERVER.port}/"
  config.openstax_application_id = 'secret'
  config.openstax_application_secret = 'secret'
  config.account_user_mapper = User
  config.logout_via = :delete
  config.max_matching_accounts = 47
end
