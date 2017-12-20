require 'spec_helper'

module OpenStax
  module Accounts

    RSpec.describe SyncAccounts, type: :routine do

      it 'can sync accounts' do
        controller_class = ::Api::ApplicationUsersController
        uuid_1 = SecureRandom.uuid
        uuid_2 = SecureRandom.uuid
        support_identifier_1 = "cs_#{SecureRandom.hex(4)}"
        support_identifier_2 = "cs_#{SecureRandom.hex(4)}"
        allow_any_instance_of(controller_class).to(
          receive(:updates) do |controller|
            controller.render json: [
              {
                id: 1,
                application_id: 1,
                user: {
                  id: 2,
                  username: 'user',
                  uuid: uuid_1,
                  support_identifier: support_identifier_1,
                  self_reported_role: 'instructor'
                },
                unread_updates: 1,
                default_contact_info_id: 1
              },
              {
                id: 3,
                application_id: 1,
                user: {
                  id: 4,
                  uuid: uuid_2,
                  support_identifier: support_identifier_2,
                  username: 'fuego'
                },
                unread_updates: 2,
                default_contact_info_id: 5
              }
            ]
          end
        )

        account = FactoryBot.create :openstax_accounts_account, username: 'u', openstax_uid: 2
        account.syncing = true

        begin
          OpenStax::Accounts.configuration.enable_stubbing = false
          expect(account.reload.openstax_uid).to eq 2
          expect(account.username).to eq 'u'
          expect(Account.find_by(openstax_uid: 4)).to be_nil

          controller_class.last_action = nil
          controller_class.last_json = nil

          expect { SyncAccounts.call }.to change { Account.count }.by(1)

          account2 = Account.find_by(openstax_uid: 4)

          expect(account.reload.openstax_uid).to eq 2
          expect(account.username).to eq 'user'
          expect(account.role).to eq 'instructor'
          expect(account.uuid).to eq uuid_1
          expect(account.support_identifier).to eq support_identifier_1
          expect(account2.username).to eq 'fuego'
          expect(account2.uuid).to eq uuid_2
          expect(account2.support_identifier).to eq support_identifier_2

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [
            {'user_id' => 2, 'read_updates' => 1}, {'user_id' => 4, 'read_updates' => 2}
          ]

          controller_class.last_action = nil
          controller_class.last_json = nil

          expect { SyncAccounts.call }.not_to change { Account.count }

          expect(account.reload.openstax_uid).to eq 2
          expect(account.username).to eq 'user'
          expect(account2.reload.openstax_uid).to eq 4
          expect(account2.username).to eq 'fuego'

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [
            {'user_id' => 2, 'read_updates' => 1}, {'user_id' => 4, 'read_updates' => 2}
          ]
        ensure
          OpenStax::Accounts.configuration.enable_stubbing = true
        end
      end

    end

  end
end
