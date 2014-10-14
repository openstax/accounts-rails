module OpenStax
  module Accounts
    class AccountsSearch

      lev_handler transaction: :no_transaction

      uses_routine OpenStax::Utilities::KeywordSearchHandler,
                   as: :search_handler,
                   translations: { outputs: {type: :verbatim} }

      protected

      def authorized?
        true
      end

      def handle
        config = OpenStax::Accounts.configuration
        run(:search_handler, params: params,
                             search_routine: OpenStax::Accounts::SearchAccounts,
                             search_relation: OpenStax::Accounts::Account.unscoped)
      end

    end
  end
end
