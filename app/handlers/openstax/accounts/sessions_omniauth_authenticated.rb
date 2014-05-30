module OpenStax
  module Accounts

    class SessionsOmniauthAuthenticated

      lev_handler

      protected

      def setup
        @auth_data = request.env['omniauth.auth']
      end

      def authorized?
        @auth_data.provider == "openstax"
      end

      def handle
        outputs[:accounts_user_to_sign_in] = user_to_sign_in
      end

      def user_to_sign_in
        return caller if 
          !caller.nil? && 
          !caller.is_anonymous? &&
          caller.openstax_uid == @auth_data.uid

        existing_user = User.where(openstax_uid: @auth_data.uid).first
        return existing_user if !existing_user.nil?

        new_user = User.create do |user|
          user.openstax_uid = @auth_data.uid
          user.username     = @auth_data.info.nickname
          user.first_name   = @auth_data.info.first_name
          user.last_name    = @auth_data.info.last_name
          user.full_name    = @auth_data.info.name
          user.title        = @auth_data.info.title
          user.access_token = @auth_data.credentials.token
        end

        transfer_errors_from(new_user, {type: :verbatim})

        new_user
      end
    end

  end
end