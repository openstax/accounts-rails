FactoryGirl.define do
  factory :openstax_accounts_user, :class => OpenStax::Accounts::User do
    sequence(:username){ |n| "Application #{n}" }
    sequence(:openstax_uid){ |n| n }
  end
end
