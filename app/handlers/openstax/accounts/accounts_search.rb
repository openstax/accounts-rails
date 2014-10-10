module OpenStax
  module Accounts
    class AccountsSearch

      lev_handler transaction: :no_transaction

      uses_routine OpenStax::Utilities::SearchHandler,
                   as: :search_handler,
                   translations: { outputs: {type: :verbatim} }

      protected

      def authorized?
        true
      end

      def handle
        config = OpenStax::Accounts.configuration
        run(:search_handler, query, search_routine: OpenStax::Accounts::SearchAccounts,
                                    search_relation: OpenStax::Accounts::Account.unscoped,
                                    min_characters: config.min_search_characters,
                                    max_items: config.max_search_items)
      end

    end
  end
end
