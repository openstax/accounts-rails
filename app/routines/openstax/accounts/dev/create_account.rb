# Routine for creating an account, only for use when stubbing and not on production.

module OpenStax
  module Accounts
    module Dev
      class CreateAccount
        lev_routine

        protected

        def exec(inputs={})
          fatal_error(code: :cannot_create_account_in_production) if Rails.env.production?
          fatal_error(code: :can_only_create_account_when_stubbing) \
            unless OpenStax::Accounts.configuration.enable_stubbing?

          username = inputs[:username]
          if username.blank?
            while username.blank? || Account.where(username: username).exists? do
              username = SecureRandom.hex(3).to_s
            end
          else
            fatal_error(
              code: :account_already_exists,
              message: "One or more accounts with username \"#{username}\" already exist."
            ) if Account.where(username: username).exists?
          end

          outputs.account = OpenStax::Accounts::Account.create(
            openstax_uid: -SecureRandom.hex(4).to_i(16)/2,
            access_token: SecureRandom.hex.to_s,
            username: username,
            role: inputs[:role] || :unknown_role,
            uuid: SecureRandom.uuid,
            support_identifier: "cs_#{SecureRandom.hex(4)}",
            school_type: inputs[:school_type] || :unknown_school_type,
            school_location: inputs[:school_location] || :unknown_school_location,
            is_test: true
          )

          transfer_errors_from(outputs.account, {type: :verbatim}, true)
        end
      end
    end
  end
end
