OpenStax::Accounts.configure do |config|
  config.openstax_accounts_url = 'http://localhost:2999/'
  config.openstax_application_id = SECRET_SETTINGS[:openstax_application_id]
  config.openstax_application_secret = SECRET_SETTINGS[:openstax_application_secret]
  config.enable_stubbing = false
end
