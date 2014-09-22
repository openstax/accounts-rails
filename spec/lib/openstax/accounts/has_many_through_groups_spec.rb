module OpenStax
  module Accounts
    describe HasManyThroughGroups do
      let!(:account_1) { FactoryGirl.create(:openstax_accounts_account,
                         username: 'some_user',
                         openstax_uid: 1) }
      let!(:user_1)    { User.create(:account => account_1) }

      let!(:account_2) { FactoryGirl.create(:openstax_accounts_account,
                         username: 'another_user',
                         openstax_uid: 2) }
      let!(:user_2)    { User.create(:account => account_2) }

      let!(:group_nesting) { FactoryGirl.create(:openstax_accounts_group_nesting) }

      before(:each) do
        group_nesting.member_group.add_member(account_1)
      end

      it 'allows users to retrieve all nested has_many_through_groups objects' do
        expect(user_1.ownerships).to be_empty

        o = Ownership.new
        o.owner = user_2
        o.save!

        expect(user_1.reload.ownerships).to be_empty

        o2 = Ownership.new
        o2.owner = user_1
        o2.save!

        expect(user_1.reload.ownerships).to include(o2)

        o3 = Ownership.new
        o3.owner = group_nesting.member_group
        o3.save!

        expect(user_1.reload.ownerships).to include(o2)
        expect(user_1.ownerships).to include(o3)

        o4 = Ownership.new
        o4.owner = group_nesting.container_group
        o4.save!

        expect(user_1.reload.ownerships).to include(o2)
        expect(user_1.ownerships).to include(o3)
        expect(user_1.ownerships).to include(o4)
      end

    end
  end
end
