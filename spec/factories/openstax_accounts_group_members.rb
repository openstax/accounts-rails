# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openstax_accounts_group_member, :class => 'GroupMember' do
    group ""
    user ""
  end
end
