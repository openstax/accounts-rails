module OpenStax
  module Accounts

    class SessionsCallback

      lev_handler

      protected

      def setup
        @auth_data = request.env['omniauth.auth']
      end

      def authorized?
        @auth_data.provider == "openstax"
      end

      def handle
        # Don't worry if the account is logged in or not beforehand.
        # Just assume that they aren't.

        # http://apidock.com/rails/v4.0.2/ActiveRecord/Relation/find_or_create_by
        begin
          outputs[:account] = Account.find_or_create_by(openstax_uid: @auth_data.uid) do |account|
            account.username     = @auth_data.info.nickname
            account.first_name   = @auth_data.info.first_name
            account.last_name    = @auth_data.info.last_name
            account.full_name    = @auth_data.info.name
            account.title        = @auth_data.info.title
            account.access_token = @auth_data.credentials.token

            # Gracefully handle absent and unknown faculty status info
            if @auth_data.extra.raw_info.present?
              begin
                account.faculty_status = @auth_data.extra.raw_info['faculty_status'] || :no_faculty_info
              rescue ArgumentError => ee
                account.faculty_status = :no_faculty_info
              end
            end
          end
        rescue ActiveRecord::RecordNotUnique
          retry
        end

        transfer_errors_from(outputs[:account], {type: :verbatim})
      end

    end

  end
end
