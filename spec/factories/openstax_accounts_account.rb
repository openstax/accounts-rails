FactoryGirl.define do
  factory :openstax_accounts_account, :class => OpenStax::Accounts::Account do
    openstax_uid { -SecureRandom.hex.to_i(16) }
    username     { SecureRandom.hex }
    access_token { SecureRandom.hex }
  end
end
