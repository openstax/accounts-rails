module OpenStax
  module Accounts
    module Dev
      class AccountsCreate
        lev_handler

        paramify :create do
          attribute :username, type: String
          attribute :role, type: String
        end

        uses_routine OpenStax::Accounts::Dev::CreateAccount,
                     as: :create_account,
                     translations: { inputs: { scope: :create }, outputs: { type: :verbatim } }

        protected

        def authorized?
          !Rails.env.production? && OpenStax::Accounts.configuration.enable_stubbing?
        end

        def handle
          run(:create_account, create_params.as_hash(:username, :role))
        end
      end
    end
  end
end
