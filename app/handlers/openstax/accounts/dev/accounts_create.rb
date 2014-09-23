module OpenStax
  module Accounts

    module Dev
      class AccountsCreate

        lev_handler

        paramify :create do
          attribute :username, type: String
          validates :username, presence: true
        end

        uses_routine OpenStax::Accounts::Dev::CreateAccount,
                     as: :create_account,
                     translations: { inputs: { scope: :create },
                                     outputs: { type: :verbatim } }

        protected

        def authorized?
          !Rails.env.production? && OpenStax::Accounts.configuration.enable_stubbing?
        end

        def handle; debugger
          run(:create_account, create_params.as_hash(:username))
        end

      end 
    end

  end
end