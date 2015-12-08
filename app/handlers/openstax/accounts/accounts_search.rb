module OpenStax
  module Accounts
    class AccountsSearch

      lev_handler outputs: { _verbatim: { name: OpenStax::Accounts::SearchAccounts,
                                          as: :search } }

      paramify :search do
        attribute :type, type: String
        attribute :query, type: String
        attribute :order_by, type: String
        attribute :page, type: Integer
        attribute :per_page, type: Integer
      end

      protected

      def initialize
        @min_characters = OpenStax::Accounts.configuration.min_search_characters
        @max_items = OpenStax::Accounts.configuration.max_search_items
      end

      def authorized?
        OSU::AccessPolicy.action_allowed?(:search, caller, Account)
      end

      def handle
        case search_params.type
        when 'Username'
          query = "username:\"#{search_params.query}\""
        when 'Name'
          query = "name:\"#{search_params.query}\""
        when 'First Name'
          query = "first_name:\"#{search_params.query}\""
        when 'Last Name'
          query = "last_name:\"#{search_params.query}\""
        when 'Email'
          query = "email:\"#{search_params.query}\""
        else
          query = search_params.query || ''
        end

        fatal_error(code: :query_too_short,
                    message: "The provided query is too short (minimum #{
                      @min_characters} characters).") \
          if !@min_characters.nil? && query.length < @min_characters

        params = {query: search_params.query,
                  order_by: search_params.order_by,
                  page: search_params.page,
                  per_page: search_params.per_page}
        run(:search, params)

        if !@max_items.nil? && result.total_count > @max_items
          fatal_error(code: :too_many_items,
                      message: "The number of matches exceeded the allowed limit of #{
                        @max_items} matches. Please refine your query and try again.")
        end
      end

    end
  end
end
