# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openstax_accounts_group_nesting, :class => OpenStax::Accounts::GroupNesting do
    association :container_group, factory: :openstax_accounts_group
    association :member_group, factory: :openstax_accounts_group
  end
end
