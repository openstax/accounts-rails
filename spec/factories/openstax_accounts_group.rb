# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openstax_accounts_group, :class => OpenStax::Accounts::Group do
    openstax_uid { -SecureRandom.hex.to_i(16) }
    name "MyGroup"
    is_public false
  end
end
