# Routine for searching for accounts
#
# Caller provides a query and some options.  The query follows the rules of
# https://github.com/bruce/keyword_search, e.g.:
#
#   "username:jps,richb" --> returns the "jps" and "richb" accounts
#   "name:John" --> returns accounts with first, last, or full name starting with "John"
#
# Query terms can be combined, e.g. "username:jp first_name:john"
#
# There are currently two options to control query pagination:
#
#   :per_page -- the max number of results to return (default: 20)
#   :page     -- the zero-indexed page to return (default: 0)

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
          while username.nil? || Account.where(username: username).any? do 
            username = SecureRandom.hex(3).to_s
          end

          account = OpenStax::Accounts::Account.new

          account.openstax_uid = -SecureRandom.hex.to_i(16)
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
