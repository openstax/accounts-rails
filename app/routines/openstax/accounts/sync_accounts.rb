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

        return if OpenStax::Accounts.configuration.enable_stubbing?

        response = OpenStax::Accounts.get_application_account_updates

        app_accounts = []
        app_accounts_rep = OpenStax::Accounts::Api::V1::ApplicationAccountsRepresenter
                             .new(app_accounts)
        app_accounts_rep.from_json(response.body)

        return if app_accounts.empty?

        app_accounts_hash = {}
        app_accounts.each do |app_account|
          account = OpenStax::Accounts::Account.where(
            :openstax_uid => app_account.account.openstax_uid).first
          account.syncing_with_accounts = true
          next unless account.update_attributes(
            app_account.account.attributes.slice(*SYNC_ATTRIBUTES))
          app_accounts_hash[app_account.id] = app_account.unread_updates
        end

        OpenStax::Accounts.mark_updates_as_read(app_accounts_hash)

      end

    end

  end
end
