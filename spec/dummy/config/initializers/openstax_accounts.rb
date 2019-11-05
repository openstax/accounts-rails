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

  # these values copied from the Accounts development env values
  config.sso_secret_key = '265127c36133669bedcf47f326e64e22623c1be35fffe04199f0d86bf45a3485'
  config.sso_cookie_name = 'ox'
  config.sso_secret_salt = 'ox-shared-salt'
end
