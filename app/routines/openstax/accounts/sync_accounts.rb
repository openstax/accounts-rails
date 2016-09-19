# Routine for getting account updates from the Accounts server
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    class SyncAccounts

      SYNC_ATTRIBUTES = ['username', 'first_name', 'last_name', 'full_name', 'title']

      lev_routine transaction: :no_transaction

      protected

      def exec(options={})

        return if OpenStax::Accounts.configuration.enable_stubbing?

        response = OpenStax::Accounts::Api.get_application_account_updates

        app_accounts = []
        app_accounts_rep = OpenStax::Accounts::Api::V1::ApplicationAccountsRepresenter
                           .new(app_accounts)
        app_accounts_rep.from_json(response.body)

        return if app_accounts.empty?

        updated_app_accounts = []
        app_accounts.each do |app_account|
          account = OpenStax::Accounts::Account.where(
            :openstax_uid => app_account.account.openstax_uid
          ).first || app_account.account
          account.syncing = true

          if account != app_account.account
            SYNC_ATTRIBUTES.each do |attribute|
              account.send("#{attribute}=", app_account.account.send(attribute))
            end
          end

          next unless account.save

          updated_app_accounts << {user_id: account.openstax_uid,
                                   read_updates: app_account.unread_updates}
        end

        OpenStax::Accounts::Api.mark_account_updates_as_read(updated_app_accounts)

      end

    end

  end
end
