# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openstax_accounts_group_nesting, :class => 'GroupNesting' do
    member_group ""
    container_group ""
  end
end
