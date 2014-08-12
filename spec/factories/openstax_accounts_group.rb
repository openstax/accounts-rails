# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openstax_accounts_group, :class => OpenStax::Accounts::Group do
    name "MyGroup"
    is_public false
    cached_subtree_group_ids nil
    cached_supertree_group_ids nil
  end
end
