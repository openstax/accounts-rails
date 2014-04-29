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

        app_users = []
        app_users_rep = OpenStax::Accounts::Api::V1::ApplicationUsersRepresenter.new(app_users)
        app_users_rep.from_json(response.body)

        return if app_users.empty?

        app_users_hash = {}

        app_users.each do |app_user|
          user = User.where(:openstax_uid => app_user.user.openstax_uid).first
          user.updating_from_accounts = true
          next unless user.update_attributes(app_user.user.attributes)
          app_users_hash[app_user.id] = app_user.unread_updates
        end

        OpenStax::Accounts.application_users_updated(app_users_hash)

      end

    end

  end
end
