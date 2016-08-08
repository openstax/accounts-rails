require 'spec_helper'

module OpenStax
  module Accounts

    describe SyncGroups, type: :routine do

      it 'can sync groups' do
        controller_class = ::Api::ApplicationGroupsController
        allow_any_instance_of(controller_class).to(
          receive(:updates) do |controller|
            controller.render :json => [{id: 1, application_id: 1,
                                         group: {id: 2, name: 'M', members: [], owners: [],
                                                 nestings: [{container_group_id: 2,
                                                             member_group_id: 3}]},
                                         unread_updates: 1, default_contact_info_id: 1},
                                        {id: 3, application_id: 1,
                                         group: {id: 3, name: 'Fuego\'s Deputies',
                                                 members: [{group_id: 3,
                                                            user: {id: 2, username: 'User'}}],
                                                 owners: [{group_id: 3,
                                                           user: {id: 3, username: 'Fuego'}}],
                                                 nestings: []},
                                         unread_updates: 2, default_contact_info_id: 5}]
          end)

        u = OpenStax::Accounts::Account.new
        u.openstax_uid = 2
        u.username = 'User'
        u.syncing = true
        u.save!

        u2 = OpenStax::Accounts::Account.new
        u2.openstax_uid = 3
        u2.username = 'Fuego'
        u2.syncing = true
        u2.save!

        g = OpenStax::Accounts::Group.new
        g.name = 'Member Group'
        g.openstax_uid = 2
        g.syncing = true
        g.save!

        gm = GroupMember.new
        gm.group = g
        gm.user = u
        gm.save!

        g2 = OpenStax::Accounts::Group.new
        g2.name = 'Container Group'
        g2.openstax_uid = 4
        g2.syncing = true
        g2.save!

        go = GroupOwner.new
        go.group = g2
        go.user = u
        go.save!

        gn = GroupNesting.new
        gn.container_group = g2
        gn.member_group = g
        gn.save!

        begin
          OpenStax::Accounts.configuration.enable_stubbing = false
          expect(Group.count).to eq 2
          expect(Group.first.openstax_uid).to eq 2
          expect(Group.first.name).to eq 'Member Group'
          expect(Group.first.members).to include u
          expect(Group.last.openstax_uid).to eq 4
          expect(Group.last.name).to eq 'Container Group'
          expect(Group.last.member_groups).to include g
          expect(Group.last.owners).to include u

          controller_class.last_action = nil
          controller_class.last_json = nil

          SyncGroups.call
          expect(Group.count).to eq 3
          expect(Group.first.openstax_uid).to eq 2
          expect(Group.first.name).to eq 'M'
          expect(Group.first.member_groups).to include Group.last
          expect(Group.all.second.openstax_uid).to eq 4
          expect(Group.all.second.name).to eq 'Container Group'
          expect(Group.all.second.member_groups).to include Group.first
          expect(Group.last.openstax_uid).to eq 3
          expect(Group.last.name).to eq 'Fuego\'s Deputies'
          expect(Group.last.owners).to include Account.last
          expect(Group.last.members).to include Account.first

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [{'group_id' => 2, 'read_updates' => 1},
                                                    {'group_id' => 3, 'read_updates' => 2}]

          controller_class.last_action = nil
          controller_class.last_json = nil

          SyncGroups.call
          expect(Group.count).to eq 3
          expect(Group.first.openstax_uid).to eq 2
          expect(Group.first.name).to eq 'M'
          expect(Group.first.member_groups).to include Group.last
          expect(Group.all.second.openstax_uid).to eq 4
          expect(Group.all.second.name).to eq 'Container Group'
          expect(Group.all.second.member_groups).to include Group.first
          expect(Group.last.openstax_uid).to eq 3
          expect(Group.last.name).to eq 'Fuego\'s Deputies'
          expect(Group.last.owners).to include Account.last
          expect(Group.last.members).to include Account.first

          expect(controller_class.last_action).to eq :updated
          expect(controller_class.last_json).to eq [{'group_id' => 2, 'read_updates' => 1},
                                                    {'group_id' => 3, 'read_updates' => 2}]
        ensure
          OpenStax::Accounts.configuration.enable_stubbing = true
        end
      end

    end

  end
end
