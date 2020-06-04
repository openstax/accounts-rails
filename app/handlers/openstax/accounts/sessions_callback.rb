module OpenStax
  module Accounts
    class SessionsCallback
      lev_handler

      protected

      def setup
        @auth_data = request.env['omniauth.auth']
      end

      def authorized?
        @auth_data.provider == 'openstax'
      end

      def handle
        # Don't worry if the account is logged in or not beforehand. Just assume that they aren't.
        # tap is used because we want the block to always run (not just when initializing)
        begin
          outputs.account = Account.find_or_initialize_by(uuid: @auth_data.uid).tap do |account|
            account.access_token = @auth_data.credentials.token

            raw_info = @auth_data.extra.raw_info
            raw_info = raw_info.merge openstax_uid: raw_info[:id]
            OpenStax::Accounts::Account::SYNC_ATTRIBUTES.each do |attribute|
              begin
                account.send "#{attribute}=", raw_info[attribute]
              rescue ArgumentError
                # Ignore errors, for example if enum values are invalid
              end
            end

            # Gracefully handle absent and unknown enum values
            account.faculty_status ||= :no_faculty_info
            account.role ||= :unknown_role
            account.school_type ||= :unknown_school_type
            account.school_location ||= :unknown_school_location
          end

          outputs.account.save if outputs.account.changed?
        rescue ActiveRecord::RecordNotUnique
          retry
        end

        transfer_errors_from(outputs.account, type: :verbatim)
      end
    end
  end
end
