# Routine for getting account updates from the Accounts server
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    class SyncAccounts

      SYNC_ATTRIBUTES = ['username', 'first_name', 'last_name',
                         'full_name', 'title']

      lev_routine transaction: :no_transaction
      
      protected
      
      def exec(options={})

        begin
          OpenStax::Accounts.syncing = true

          return if OpenStax::Accounts.configuration.enable_stubbing?

          response = OpenStax::Accounts.get_application_user_updates

          app_users = []
          app_users_rep = OpenStax::Accounts::Api::V1::ApplicationUsersRepresenter
                             .new(app_users)
          app_users_rep.from_json(response.body)

          return if app_users.empty?

          updated_app_users = []
          app_users.each do |app_user|
            account = OpenStax::Accounts::Account.where(
              :openstax_uid => app_user.user.openstax_uid).first
            next unless account.update_attributes(
              app_user.user.attributes.slice(*SYNC_ATTRIBUTES))
            updated_app_users << {:id => app_user.id,
                                  :read_updates => app_user.unread_updates}
          end

          OpenStax::Accounts.mark_account_updates_as_read(updated_app_users)
        ensure
          OpenStax::Accounts.syncing = false
        end

      end

    end

  end
end
