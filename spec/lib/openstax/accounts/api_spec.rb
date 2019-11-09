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
        Api.request(:post, 'dummy', params: { test: true })
        expect(::Api::DummyController.last_action).to eq :dummy
        expect(::Api::DummyController.last_params).to include 'test' => 'true'
      end

      context 'users' do
        before(:each) { reset(::Api::UsersController) }
        let!(:account) { FactoryBot.create :openstax_accounts_account }

        it 'makes api call to users index' do
          Api.search_accounts('something')
          expect(::Api::UsersController.last_action).to eq :index
          expect(::Api::UsersController.last_params).to include q: 'something'
        end

        it 'makes api call to user update' do
          Api.update_account(account)
          expect(::Api::UsersController.last_action).to eq :update
          expect(::Api::UsersController.last_json).to include account.attributes.slice(
            'username', 'first_name', 'last_name', 'full_name', 'title'
          )
        end

        it 'makes api call to unclaimed user create by email' do
          Api.find_or_create_account(email: 'dummy@dum.my', is_test: true)
          expect(::Api::UsersController.last_action).to eq :create
          expect(::Api::UsersController.last_json).to(
            include('email' => 'dummy@dum.my', 'is_test' => true)
          )
        end

        it 'makes api call to unclaimed user create by username' do
          Api.find_or_create_account(username: 'dummy', is_test: false)
          expect(::Api::UsersController.last_action).to eq :create
          expect(::Api::UsersController.last_json).to(
            include('username' => 'dummy', 'is_test' => false)
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
    end
  end
end
