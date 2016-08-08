require 'spec_helper'

module OpenStax
  module Accounts

    describe SyncAccounts, type: :routine do

      it 'can sync accounts' do
        controller_class = ::Api::ApplicationUsersController
        allow_any_instance_of(controller_class).to(
          receive(:updates) do |controller|
            controller.render :json => [{id: 1, application_id: 1,
                                        user: {id: 2, username: 'user'},
                                        unread_updates: 1, default_contact_info_id: 1},
                                        {id: 3, application_id: 1,
                                        user: {id: 4, username: 'fuego'},
                                        unread_updates: 2, default_contact_info_id: 5}]
          end
        )

        account = OpenStax::Accounts::Account.new
        account.username = 'u'
        account.openstax_uid = 2
        account.syncing = true
        account.save!

        begin
          OpenStax::Accounts.configuration.enable_stubbing = false
          expect(Account.count).to eq 1
          expect(Account.first.openstax_uid).to eq 2
          expect(Account.first.username).to eq 'u'

          controller_class.last_action = nil
          controller_class.last_json = nil
          SyncAccounts.call
          expect(Account.count).to eq 2
          expect(Account.first.openstax_uid).to eq 2
          expect(Account.first.username).to eq 'user'
          expect(Account.last.openstax_uid).to eq 4
          expect(Account.last.username).to eq 'fuego'

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [{'user_id' => 2, 'read_updates' => 1},
                                                    {'user_id' => 4, 'read_updates' => 2}]

          controller_class.last_action = nil
          controller_class.last_json = nil

          SyncAccounts.call
          expect(Account.count).to eq 2
          expect(Account.first.openstax_uid).to eq 2
          expect(Account.first.username).to eq 'user'
          expect(Account.last.openstax_uid).to eq 4
          expect(Account.last.username).to eq 'fuego'

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [{'user_id' => 2, 'read_updates' => 1},
                                                    {'user_id' => 4, 'read_updates' => 2}]
        ensure
          OpenStax::Accounts.configuration.enable_stubbing = true
        end
      end

    end

  end
end
