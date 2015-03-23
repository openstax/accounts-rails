module OpenStax
  module Accounts
    class SearchAccounts
      
      lev_routine transaction: :no_transaction

      uses_routine SearchLocalAccounts,
                   as: :local_search,
                   translations: { outputs: { type: :verbatim } }
      
      protected

      def exec(*args)
        params = args.last.is_a?(Hash) ? args.pop : {}
        params[:q] ||= args[0]
        params[:ob] ||= args[1]
        params[:pp] ||= args[2]
        params[:p] ||= args[3]

        query = params[:query] || params[:q]
        if !OpenStax::Accounts.configuration.enable_stubbing? && \
           query =~ /email:/
          # Delegate to Accounts
          response = OpenStax::Accounts::Api.search_application_accounts(query)
          OpenStax::Accounts::Api::V1::AccountSearchRepresenter \
            .new(outputs).from_json(response.body)
        else
          # Local search
          run(:local_search, params)
        end

      end

    end
  end
end
