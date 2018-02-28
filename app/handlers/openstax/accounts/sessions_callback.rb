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
          outputs[:account] = Account.find_or_initialize_by(openstax_uid: @auth_data.uid).tap do |account|
            account.username     = @auth_data.info.nickname
            account.first_name   = @auth_data.info.first_name
            account.last_name    = @auth_data.info.last_name
            account.full_name    = @auth_data.info.name
            account.title        = @auth_data.info.title
            account.access_token = @auth_data.credentials.token

            # Gracefully handle absent and unknown faculty status info
            raw_info = @auth_data.extra.raw_info
            if raw_info.present?
              begin
                account.faculty_status = raw_info['faculty_status'] || :no_faculty_info
              rescue ArgumentError => ee
                account.faculty_status = :no_faculty_info
              end

              begin
                account.role = raw_info['self_reported_role'] || :unknown_role
              rescue ArgumentError => ee
                account.role = :unknown_role
              end

              begin
                account.school_type = raw_info['school_type'] || :unknown_school_type
              rescue ArgumentError => ee
                account.school_type = :unknown_school_type
              end

              account.uuid = raw_info['uuid']
              account.support_identifier = raw_info['support_identifier']
              account.is_test = raw_info['is_test']
            end
          end

          outputs[:account].save if outputs[:account].changed?
        rescue ActiveRecord::RecordNotUnique
          retry
        end

        transfer_errors_from(outputs[:account], {type: :verbatim})
      end

    end

  end
end
