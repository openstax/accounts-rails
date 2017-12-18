require 'spec_helper'

module OpenStax
  module Accounts
    RSpec.describe Api do

      let!(:account) { OpenStax::Accounts::Account.create(username: 'some_user',
                         first_name: 'Some', last_name: 'User', full_name: 'SomeUser',
                         title: 'Sir', openstax_uid: 1, access_token: 'secret') }

      def reset(controller)
        controller.last_action = nil
        controller.last_json = nil
        controller.last_params = nil
      end

      it 'makes api requests' do
        reset(::Api::DummyController)
        Api.request(:post, 'dummy', :params => {:test => true})
        expect(::Api::DummyController.last_action).to eq :dummy
        expect(::Api::DummyController.last_params).to include 'test' => 'true'
      end

      context 'users' do
        before(:each) { reset(::Api::UsersController) }
        let!(:account) { FactoryBot.create :openstax_accounts_account }

        it 'makes api call to users index' do
          Api.search_accounts('something')
          expect(::Api::UsersController.last_action).to eq :index
          expect(::Api::UsersController.last_params).to include :q => 'something'
        end

        it 'makes api call to user update' do
          Api.update_account(account)
          expect(::Api::UsersController.last_action).to eq :update
          expect(::Api::UsersController.last_json).to include(
            account.attributes.slice('username', 'first_name',
              'last_name', 'full_name', 'title'))
        end

        it 'makes api call to (temp) user create by email' do
          Api.find_or_create_account(email: 'dummy@dum.my')
          expect(::Api::UsersController.last_action).to eq :create
          expect(::Api::UsersController.last_json).to(
            include('email' => 'dummy@dum.my')
          )
        end

        it 'makes api call to (temp) user create by username' do
          Api.find_or_create_account(username: 'dummy')
          expect(::Api::UsersController.last_action).to eq :create
          expect(::Api::UsersController.last_json).to(
            include('username' => 'dummy')
          )
        end
      end

      context 'application_users' do
        before(:each) { reset(::Api::ApplicationUsersController) }

        it 'makes api call to application_users index' do
          Api.search_application_accounts('something')
          expect(::Api::ApplicationUsersController.last_action).to eq :index
          expect(::Api::ApplicationUsersController.last_params).to include :q => 'something'
        end

        it 'makes api call to application_users updates' do
          Api.get_application_account_updates
          expect(::Api::ApplicationUsersController.last_action).to eq :updates
          expect(::Api::ApplicationUsersController.last_params).to include limit: "250"
        end

        it 'does not limit updates call if param blank' do
          allow(OpenStax::Accounts.configuration).to receive(:max_user_updates_per_request) { "" }
          Api.get_application_account_updates
          expect(::Api::ApplicationUsersController.last_action).to eq :updates
          expect(::Api::ApplicationUsersController.last_params.keys).not_to include "limit"
        end

        it 'makes api call to application_users updated' do
          Api.mark_account_updates_as_read([{id: 1, read_updates: 1}])
          expect(::Api::ApplicationUsersController.last_action).to eq :updated
          expect(::Api::ApplicationUsersController.last_json).to include(
            {'id' => 1, 'read_updates' => 1})
        end
      end

      context 'groups' do
        before(:each) { reset(::Api::GroupsController) }

        let!(:account) { FactoryBot.create :openstax_accounts_account }
        let!(:group)   { FactoryBot.create :openstax_accounts_group }

        it 'makes api call to groups create' do
          Api.create_group(account, group)
          expect(::Api::GroupsController.last_action).to eq :create
          expect(::Api::GroupsController.last_json).to include(
            {'name' => 'MyGroup', 'is_public' => false})
        end

        it 'makes api call to group update' do
          group.save!
          Api.update_group(account, group)
          expect(::Api::GroupsController.last_action).to eq :update
          expect(::Api::GroupsController.last_params).to include(
            {'id' => group.openstax_uid.to_s})
          expect(::Api::GroupsController.last_json).to include(
            {'name' => group.name, 'is_public' => group.is_public})
        end

        it 'makes api call to group destroy' do
          group.save!
          Api.destroy_group(account, group)
          expect(::Api::GroupsController.last_action).to eq :destroy
          expect(::Api::GroupsController.last_params).to include(
            {'id' => group.openstax_uid.to_s})
        end
      end

      context 'group_members' do
        before(:each) { reset(::Api::GroupMembersController) }

        let!(:account) { FactoryBot.create :openstax_accounts_account }
        let!(:group_member)   { FactoryBot.build :openstax_accounts_group_member }

        it 'makes api call to group_members create' do
          Api.create_group_member(account, group_member)
          expect(::Api::GroupMembersController.last_action).to eq :create
          expect(::Api::GroupMembersController.last_params).to include(
            {'group_id' => group_member.group_id.to_s,
             'user_id' => group_member.user_id.to_s})
        end

        it 'makes api call to group_member destroy' do
          group_member.save!
          Api.destroy_group_member(account, group_member)
          expect(::Api::GroupMembersController.last_action).to eq :destroy
          expect(::Api::GroupMembersController.last_params).to include(
            {'group_id' => group_member.group_id.to_s,
             'user_id' => group_member.user_id.to_s})
        end
      end

      context 'group_owners' do
        before(:each) { reset(::Api::GroupOwnersController) }

        let!(:account)      { FactoryBot.create :openstax_accounts_account }
        let!(:group_owner) { FactoryBot.build :openstax_accounts_group_owner }

        it 'makes api call to group_owners create' do
          Api.create_group_owner(account, group_owner)
          expect(::Api::GroupOwnersController.last_action).to eq :create
          expect(::Api::GroupOwnersController.last_params).to include(
            {'group_id' => group_owner.group_id.to_s,
             'user_id' => group_owner.user_id.to_s})
        end

        it 'makes api call to group_owner destroy' do
          group_owner.save!
          Api.destroy_group_owner(account, group_owner)
          expect(::Api::GroupOwnersController.last_action).to eq :destroy
          expect(::Api::GroupOwnersController.last_params).to include(
            {'group_id' => group_owner.group_id.to_s,
             'user_id' => group_owner.user_id.to_s})
        end
      end

      context 'group_nestings' do
        before(:each) { reset(::Api::GroupNestingsController) }

        let!(:account)      { FactoryBot.create :openstax_accounts_account }
        let!(:group_nesting) { FactoryBot.build :openstax_accounts_group_nesting }

        it 'makes api call to group_nestings (create)' do
          Api.create_group_nesting(account, group_nesting)
          expect(::Api::GroupNestingsController.last_action).to eq :create
          expect(::Api::GroupNestingsController.last_params).to include(
            {'group_id' => group_nesting.container_group_id.to_s,
             'member_group_id' => group_nesting.member_group_id.to_s})
        end

        it 'makes api call to group_nesting (destroy)' do
          group_nesting.save!
          Api.destroy_group_nesting(account, group_nesting)
          expect(::Api::GroupNestingsController.last_action).to eq :destroy
          expect(::Api::GroupNestingsController.last_params).to include(
            {'group_id' => group_nesting.container_group_id.to_s,
             'member_group_id' => group_nesting.member_group_id.to_s})
        end
      end

      context 'application_groups' do
        before(:each) { reset(::Api::ApplicationGroupsController) }

        it 'makes api call to application_groups_updates' do
          Api.get_application_group_updates
          expect(::Api::ApplicationGroupsController.last_action).to eq :updates
        end

        it 'makes api call to application_groups_updated' do
          Api.mark_group_updates_as_read([{id: 1, read_updates: 1}])
          expect(::Api::ApplicationGroupsController.last_action).to eq :updated
          expect(::Api::ApplicationGroupsController.last_json).to include(
            {'id' => 1, 'read_updates' => 1})
        end
      end

    end

  end
end
