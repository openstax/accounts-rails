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

        existing_account = Account.where(openstax_uid: @auth_data.uid).first
        return outputs[:account] = existing_account if !existing_account.nil?

        new_account = Account.create do |account|
          account.openstax_uid = @auth_data.uid
          account.username     = @auth_data.info.nickname
          account.first_name   = @auth_data.info.first_name
          account.last_name    = @auth_data.info.last_name
          account.full_name    = @auth_data.info.name
          account.title        = @auth_data.info.title
          account.access_token = @auth_data.credentials.token
        end

        transfer_errors_from(new_account, {type: :verbatim})

        outputs[:account] = new_account
      end

    end

  end
end