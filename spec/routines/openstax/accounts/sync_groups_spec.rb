require 'spec_helper'

module OpenStax
  module Accounts

    RSpec.describe SyncGroups, type: :routine do

      it 'can sync groups' do
        controller_class = ::Api::ApplicationGroupsController
        allow_any_instance_of(controller_class).to(
          receive(:updates) do |controller|
            controller.render json: [
              {
                id: 1,
                application_id: 1,
                group: {
                  id: 2,
                  name: 'M',
                  members: [],
                  owners: [],
                  nestings: [
                    {
                      container_group_id: 2,
                      member_group_id: 3
                    }
                  ]
                },
                unread_updates: 1,
                default_contact_info_id: 1
              },
              {
                id: 3,
                application_id: 1,
                group: {
                  id: 3,
                  name: 'Fuego\'s Deputies',
                  members: [
                    {
                      group_id: 3,
                      user: {
                        id: 2,
                        username: 'User'
                      }
                    }
                  ],
                  owners: [
                    {
                      group_id: 3,
                      user: {
                        id: 3,
                        username: 'Fuego'
                      }
                    }
                  ],
                  nestings: []
                },
                unread_updates: 2,
                default_contact_info_id: 5
              }
            ]
          end
        )

        u = FactoryBot.create :openstax_accounts_account, openstax_uid: 2, username: 'User'
        u.syncing = true

        u2 = FactoryBot.create :openstax_accounts_account, openstax_uid: 3, username: 'Fuego'
        u2.syncing = true

        g = FactoryBot.create :openstax_accounts_group, openstax_uid: 2, name: 'Member Group'
        g.syncing = true

        gm = FactoryBot.create :openstax_accounts_group_member, group: g, user: u

        g2 = FactoryBot.create :openstax_accounts_group, openstax_uid: 4, name: 'Container Group'
        g2.syncing = true

        go = FactoryBot.create :openstax_accounts_group_owner, group: g2, user: u

        gn = FactoryBot.create :openstax_accounts_group_nesting, container_group: g2,
                                                                 member_group: g

        begin
          OpenStax::Accounts.configuration.enable_stubbing = false
          expect(g.reload.openstax_uid).to eq 2
          expect(g.name).to eq 'Member Group'
          expect(g.members).to eq [ u ]
          expect(g2.reload.openstax_uid).to eq 4
          expect(g2.name).to eq 'Container Group'
          expect(g2.member_groups).to eq [ g ]
          expect(g2.owners).to eq [ u ]

          controller_class.last_action = nil
          controller_class.last_json = nil

          expect { SyncGroups.call }.to change { Group.count }.by(1)

          g3 = Group.find_by(openstax_uid: 3)

          expect(g.reload.openstax_uid).to eq 2
          expect(g.name).to eq 'M'
          expect(g.member_groups).to eq [ g3 ]
          expect(g2.reload.openstax_uid).to eq 4
          expect(g2.name).to eq 'Container Group'
          expect(g2.member_groups).to eq [ g ]
          expect(g3.name).to eq 'Fuego\'s Deputies'
          expect(g3.owners).to eq [ u2 ]
          expect(g3.members).to eq [ u ]

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [
            {'group_id' => 2, 'read_updates' => 1}, {'group_id' => 3, 'read_updates' => 2}
          ]

          controller_class.last_action = nil
          controller_class.last_json = nil

          expect { SyncGroups.call }.not_to change { Group.count }

          expect(g.reload.openstax_uid).to eq 2
          expect(g.name).to eq 'M'
          expect(g.member_groups).to eq [ g3 ]
          expect(g2.reload.openstax_uid).to eq 4
          expect(g2.name).to eq 'Container Group'
          expect(g2.member_groups).to eq [ g ]
          expect(g3.reload.openstax_uid).to eq 3
          expect(g3.name).to eq 'Fuego\'s Deputies'
          expect(g3.owners).to eq [ u2 ]
          expect(g3.members).to eq [ u ]

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [
            {'group_id' => 2, 'read_updates' => 1}, {'group_id' => 3, 'read_updates' => 2}
          ]
        ensure
          OpenStax::Accounts.configuration.enable_stubbing = true
        end
      end

    end

  end
end
