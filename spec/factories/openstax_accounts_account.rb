FactoryGirl.define do
  factory :openstax_accounts_account, :class => OpenStax::Accounts::Account do
    sequence(:username){ |n| "Application #{n}" }
    sequence(:openstax_uid){ |n| n }
  end
end
