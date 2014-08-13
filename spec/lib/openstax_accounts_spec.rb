module OpenStax
  describe Accounts do

    let!(:account) { OpenStax::Accounts::Account.create(username: 'some_user',
                       openstax_uid: 1, access_token: 'secret') }

    it 'makes api calls' do
      expect(Api::DummyController.last_action).to be_nil
      expect(Api::DummyController.last_params).to be_nil
      Accounts.api_call(:post, 'dummy', :params => {:test => true})
      expect(Api::DummyController.last_action).to eq :dummy
      expect(Api::DummyController.last_params).to include 'test' => 'true'
    end

    context 'users' do

      let!(:account) { FactoryGirl.create :openstax_accounts_account }

      it 'makes api call to users (index)' do
        Api::UsersController.last_action = nil
        Api::UsersController.last_params = nil
        Accounts.search_accounts('sth')
        expect(Api::UsersController.last_action).to eq :index
        expect(Api::UsersController.last_params).to include :q => 'sth'
      end

      it 'makes api call to user (update)' do
        Api::UsersController.last_action = nil
        Api::UsersController.last_params = nil
        Api::UsersController.last_json = nil
        Accounts.update_account(account)
        expect(Api::UsersController.last_action).to eq :update
        expect(Api::UsersController.last_params).to include(
          {id: account.id})
        expect(Api::UsersController.last_json).to include(
          {'id' => account.openstax_uid, 'username' => account.username})
      end

    end

    context 'application_users' do

      it 'makes api call to application_users (index)' do
        Api::ApplicationUsersController.last_action = nil
        Api::ApplicationUsersController.last_params = nil
        Accounts.search_application_accounts('sth')
        expect(Api::ApplicationUsersController.last_action).to eq :index
        expect(Api::ApplicationUsersController.last_params).to include :q => 'sth'
      end

      it 'makes api call to application_users_updates' do
        Api::ApplicationUsersController.last_action = nil
        Api::ApplicationUsersController.last_params = nil
        Accounts.get_application_account_updates
        expect(Api::ApplicationUsersController.last_action).to eq :updates
        expect(Api::ApplicationUsersController.last_params).not_to be_nil
      end

      it 'makes api call to application_users_updated' do
        Api::ApplicationUsersController.last_action = nil
        Api::ApplicationUsersController.last_json = nil
        Accounts.mark_account_updates_as_read([{id: 1, read_updates: 1}])
        expect(Api::ApplicationUsersController.last_action).to eq :updated
        expect(Api::ApplicationUsersController.last_json).to include(
          {'id' => 1, 'read_updates' => 1})
      end

    end

    context 'groups' do

      let!(:account) { FactoryGirl.create :openstax_accounts_account }
      let!(:group)   { FactoryGirl.create :openstax_accounts_group }

      it 'makes api call to groups (create)' do
        Api::GroupsController.last_action = nil
        Api::GroupsController.last_json = nil
        Accounts.create_group(account, group)
        expect(Api::GroupsController.last_action).to eq :create
        expect(Api::GroupsController.last_json).to include(
          {'name' => 'MyGroup', 'is_public' => false})
      end

      it 'makes api call to group (update)' do
        group.save!
        Api::GroupsController.last_action = nil
        Api::GroupsController.last_params = nil
        Api::GroupsController.last_json = nil
        Accounts.update_group(account, group)
        expect(Api::GroupsController.last_action).to eq :update
        expect(Api::GroupsController.last_params).to include(
          {id: group.id})
        expect(Api::GroupsController.last_json).to include(
          {'name' => group.name, 'is_public' => group.is_public})
      end

      it 'makes api call to group (destroy)' do
        group.save!
        Api::GroupsController.last_action = nil
        Api::GroupsController.last_params = nil
        Accounts.destroy_group(account, group)
        expect(Api::GroupsController.last_action).to eq :destroy
        expect(Api::GroupsController.last_params).to include(
          {id: group.id})
      end

    end

    context 'group_members' do

      let!(:account) { FactoryGirl.create :openstax_accounts_account }
      let!(:group_member)   { FactoryGirl.build :openstax_accounts_group_member }

      it 'makes api call to group_members (create)' do
        Api::GroupMembersController.last_action = nil
        Api::GroupMembersController.last_params = nil
        Api::GroupMembersController.last_json = nil
        Accounts.create_group_member(account, group_member)
        expect(Api::GroupMembersController.last_action).to eq :create
        expect(Api::GroupMembersController.last_params).to include(
          {'group_id' => group_member.group_id})
        expect(Api::GroupMembersController.last_json).to include(
          {'user_id' => group_member.user_id})
      end

      it 'makes api call to group_member (destroy)' do
        group_member.save!
        Api::GroupMembersController.last_action = nil
        Api::GroupMembersController.last_params = nil
        Accounts.destroy_group_member(account, group_member)
        expect(Api::GroupMembersController.last_action).to eq :destroy
        expect(Api::GroupMembersController.last_params).to include(
          {id: group_member.id})
      end

    end

    context 'group_owners' do

      let!(:account)      { FactoryGirl.create :openstax_accounts_account }
      let!(:group_owner) { FactoryGirl.build :openstax_accounts_group_owner }

      it 'makes api call to group_owners (create)' do
        Api::GroupOwnersController.last_action = nil
        Api::GroupOwnersController.last_params = nil
        Api::GroupOwnersController.last_json = nil
        Accounts.create_group_owner(account, group_owner)
        expect(Api::GroupOwnersController.last_action).to eq :create
        expect(Api::GroupOwnersController.last_params).to include(
          {'group_id' => group_owner.group_id})
        expect(Api::GroupOwnersController.last_json).to include(
          {'user_id' => group_owner.user_id})
      end

      it 'makes api call to group_owner (destroy)' do
        group_owner.save!
        Api::GroupOwnersController.last_action = nil
        Api::GroupOwnersController.last_params = nil
        Accounts.destroy_group_owner(account, group_owner)
        expect(Api::GroupOwnersController.last_action).to eq :destroy
        expect(Api::GroupOwnersController.last_params).to include(
          {id: group_owner.id})
      end

    end

    context 'group_nestings' do

      let!(:account)      { FactoryGirl.create :openstax_accounts_account }
      let!(:group_nesting) { FactoryGirl.build :openstax_accounts_group_nesting }

      it 'makes api call to group_nestings (create)' do
        Api::GroupNestingsController.last_action = nil
        Api::GroupNestingsController.last_params = nil
        Api::GroupNestingsController.last_json = nil
        Accounts.create_group_nesting(account, group_nesting)
        expect(Api::GroupNestingsController.last_action).to eq :create
        expect(Api::GroupNestingsController.last_params).to include(
          {'group_id' => group_nesting.container_group_id})
        expect(Api::GroupNestingsController.last_json).to include(
          {'member_group_id' => group_nesting.member_group_id})
      end

      it 'makes api call to group_nesting (destroy)' do
        group_nesting.save!
        Api::GroupNestingsController.last_action = nil
        Api::GroupNestingsController.last_params = nil
        Accounts.destroy_group_nesting(account, group_nesting)
        expect(Api::GroupNestingsController.last_action).to eq :destroy
        expect(Api::GroupNestingsController.last_params).to include(
          {id: group_nesting.id})
      end

    end

    context 'application_groups' do

      it 'makes api call to application_groups_updates' do
        Api::ApplicationGroupsController.last_action = nil
        Api::ApplicationGroupsController.last_params = nil
        Accounts.get_application_group_updates
        expect(Api::ApplicationGroupsController.last_action).to eq :updates
        expect(Api::ApplicationGroupsController.last_params).not_to be_nil
      end

      it 'makes api call to application_groups_updated' do
        Api::ApplicationGroupsController.last_action = nil
        Api::ApplicationGroupsController.last_json = nil
        Accounts.mark_group_updates_as_read([{id: 1, read_updates: 1}])
        expect(Api::ApplicationGroupsController.last_action).to eq :updated
        expect(Api::ApplicationGroupsController.last_json).to include(
          {'id' => 1, 'read_updates' => 1})
      end

    end

  end
end