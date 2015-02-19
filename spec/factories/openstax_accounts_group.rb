FactoryGirl.define do
  factory :openstax_accounts_group, :class => OpenStax::Accounts::Group do
    openstax_uid { -SecureRandom.hex(4).to_i(16)/2 }
    name "MyGroup"
    is_public false
  end
end
