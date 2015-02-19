FactoryGirl.define do
  factory :openstax_accounts_account, :class => OpenStax::Accounts::Account do
    openstax_uid { -SecureRandom.hex(4).to_i(16)/2 }
    username     { SecureRandom.hex.to_s }
    access_token { SecureRandom.hex.to_s }
  end
end
