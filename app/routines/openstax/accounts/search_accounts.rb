module OpenStax
  module Accounts
    class SearchAccounts

      lev_routine outputs: { _verbatim: { name: SearchLocalAccounts, as: :local_search } },
                  transaction: :no_transaction

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
            .new(result).from_json(response.body)
        else
          # Local search
          run(:local_search, params)
        end

      end

    end
  end
end
