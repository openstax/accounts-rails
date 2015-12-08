module OpenStax
  module Accounts

    module Dev
      class AccountsCreate

        lev_handler outputs: { _verbatim: { name: OpenStax::Accounts::Dev::CreateAccount,
                                            as: :create_account } }

        paramify :create do
          attribute :username, type: String
          validates :username, presence: true
        end

        protected

        def authorized?
          !Rails.env.production? && OpenStax::Accounts.configuration.enable_stubbing?
        end

        def handle
          run(:create_account, create_params.as_hash(:username))
        end

      end 
    end

  end
end
