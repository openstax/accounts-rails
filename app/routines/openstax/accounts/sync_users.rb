# Routine for getting user updates from Accounts
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    class SyncUsers
      
      lev_routine transaction: :no_transaction
      
      protected
      
      def exec(options={})

        return if OpenStax::Accounts.configuration.enable_stubbing?

        response = OpenStax::Accounts.application_users_updates

        app_users = OpenStruct.new
        app_users_rep = OpenStax::Accounts::Api::V1::ApplicationUsersRepresenter.new(application_users)
        app_users_rep.from_json(response.body)

        app_users_hash = {}

        app_users.each do |app_user|
          app_user.user.updating_from_accounts = true
          next unless app_user.user.save
          app_users_hash[app_user.id] = app_user.unread_updates
        end

        OpenStax::Accounts.application_users_updated(app_users_hash)

      end

    end

  end
end
