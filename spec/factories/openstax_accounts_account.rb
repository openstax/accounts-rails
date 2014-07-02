FactoryGirl.define do
  factory :openstax_accounts_account, :class => OpenStax::Accounts::Account do
    sequence(:openstax_uid) { -SecureRandom.hex.to_i(16) }
    sequence(:username) { SecureRandom.hex }
  end
end
