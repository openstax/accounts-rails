Rails.application.config.to_prepare do
  OSU::AccessPolicy.register(OpenStax::Accounts::Account, AccountAccessPolicy)
end
