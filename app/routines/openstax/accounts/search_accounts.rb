module OpenStax
  module Accounts
    class SearchAccounts
      
      lev_routine transaction: :no_transaction

      uses_routine SearchLocalAccountCache,
                   as: :search_local_account_cache,
                   translations: { outputs: {type: :verbatim} }
      
      protected

      def exec(query, options={})

        if !OpenStax::Accounts.configuration.enable_stubbing? && query =~ /email:/
          # Delegate to Accounts
          response = OpenStax::Accounts.search_application_accounts(query)
          search = Lev::Outputs.new
          OpenStax::Accounts::Api::V1::AccountSearchRepresenter.new(search)
                                                               .from_json(response.body)
          outputs[:items] = search.items
        else
          # Local search
          run(:search_local_account_cache, OpenStax::Accounts::Account.all, query, options)
        end

      end

    end
  end
end
