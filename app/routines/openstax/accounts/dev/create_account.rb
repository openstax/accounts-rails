# Routine for creating an account, only for use when stubbing and
# not on production.

module OpenStax
  module Accounts
    module Dev
      class CreateAccount
        lev_routine
              
      protected

        def exec(inputs={})
          fatal_error(:code => :cannot_create_account_in_production) if Rails.env.production?
          fatal_error(:code => :can_only_create_account_when_stubbing) if !OpenStax::Accounts.configuration.enable_stubbing?

          username = inputs[:username]
          while username.nil? || Account.where(username: username).exists? do 
            username = SecureRandom.hex(3).to_s
          end

          account = OpenStax::Accounts::Account.new

          account.openstax_uid = -SecureRandom.hex(4).to_i(16)/2
          account.access_token = SecureRandom.hex.to_s
          account.username = username

          account.save

          transfer_errors_from(account, {type: :verbatim}, true)

          outputs[:account] = account
        end

      end
    end
  end
end
