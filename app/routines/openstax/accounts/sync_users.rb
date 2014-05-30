# Routine for getting user updates from Accounts
#
# Should be scheduled to run regularly

module OpenStax
  module Accounts

    class SyncUsers

      SYNC_ATTRIBUTES = ['username', 'first_name', 'last_name',
                         'full_name', 'title']

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
          user = OpenStax::Accounts::User.where(:openstax_uid => app_user.user.openstax_uid).first
          user.updating_from_accounts = true
          next unless user.update_attributes(app_user.user.attributes.slice(*SYNC_ATTRIBUTES))
          app_users_hash[app_user.id] = app_user.unread_updates
        end

        OpenStax::Accounts.application_users_updated(app_users_hash)

      end

    end

  end
end
