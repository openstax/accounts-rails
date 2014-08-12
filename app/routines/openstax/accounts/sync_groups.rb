# Routine for getting group updates from the Accounts server
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    class SyncGroups

      SYNC_ATTRIBUTES = ['name', 'is_public', 'owners', 'members', 'groups']

      lev_routine transaction: :no_transaction
      
      protected
      
      def exec(options={})

        begin
          OpenStax::Accounts.syncing = true

          return if OpenStax::Accounts.configuration.enable_stubbing?

          response = OpenStax::Accounts.get_application_group_updates

          app_groups = []
          app_groups_rep = OpenStax::Accounts::Api::V1::ApplicationGroupsRepresenter
                             .new(app_groups)
          app_groups_rep.from_json(response.body)

          return if app_groups.empty?

          updated_app_groups = []
          app_groups.each do |app_group|
            group = OpenStax::Accounts::Group.where(
              :openstax_uid => app_group.group.openstax_uid).first
            next unless group.update_attributes(
              app_group.group.attributes.slice(*SYNC_ATTRIBUTES))
            updated_app_groups << {:id => app_group.id,
                                   :read_updates => app_group.unread_updates}
          end

          OpenStax::Accounts.mark_group_updates_as_read(updated_app_groups)
        ensure
          OpenStax::Accounts.syncing = false
        end

      end

    end

  end
end
