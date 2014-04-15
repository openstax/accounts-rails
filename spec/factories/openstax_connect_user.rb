FactoryGirl.define do
  factory :openstax_connect_user, :class => OpenStax::Connect::User do
    sequence(:username){ |n| "Application #{n}" }
    sequence(:openstax_uid){ |n| n }
  end
end
