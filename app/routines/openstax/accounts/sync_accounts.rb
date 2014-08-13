# Routine for getting account updates from the Accounts server
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    SYNC_ATTRIBUTES = ['username', 'first_name', 'last_name',
                       'full_name', 'title']

    class SyncAccounts

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

          app_user_updates = {}
          app_users.each do |app_user|
            sync_app_user(app_user, app_user_updates)
          end

          updated_app_users = app_user_updates.collect{|k,v| {user_id: k, read_updates: v}}
          OpenStax::Accounts.mark_account_updates_as_read(updated_app_users)
        ensure
          OpenStax::Accounts.syncing = false
        end

      end

      def sync_app_user(app_user, app_user_updates = {})

        account = OpenStax::Accounts::Account.where(
                    :openstax_uid => app_user.account.openstax_uid).first

        SYNC_ATTRIBUTES.each do |attribute|
          account.send("#{attribute}=", app_user.account.send(attribute))
        end

        return unless account.save

        app_user_updates[user.openstax_uid] = app_user.unread_updates

      end

    end

  end
end
