# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :openstax_accounts_group, :class => 'Group' do
    name "MyString"
    is_public false
    cached_subtree_group_ids "MyText"
    cached_supertree_group_ids "MyText"
  end
end
