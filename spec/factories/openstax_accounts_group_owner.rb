FactoryBot.define do
  factory :openstax_accounts_group_owner, class: OpenStax::Accounts::GroupOwner do
    association :group, factory: :openstax_accounts_group
    association :user, factory: :openstax_accounts_account
  end
end
