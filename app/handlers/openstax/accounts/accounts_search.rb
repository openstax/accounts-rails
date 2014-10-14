module OpenStax
  module Accounts
    class AccountsSearch < OpenStax::Utilities::KeywordSearchHandler

      class_attribute :min_characters, :max_items
      self.min_characters = OpenStax::Accounts.configuration.min_search_characters
      self.max_items = OpenStax::Accounts.configuration.max_search_items

      paramify :search do
        attribute :type, type: String
        attribute :q, type: String
        attribute :order_by, type: String
        attribute :page, type: Integer
        attribute :per_page, type: Integer
      end

      protected

      def handle
        case search_params.type
        when 'Name'
          query = "name:\"#{search_params.q}\""
        when 'Username'
          query = "username:\"#{search_params.q}\""
        when 'Email'
          query = "email:\"#{search_params.q}\""
        else
          query = search_params.q || ''
        end

        fatal_error(code: :query_too_short,
                    message: "The provided query is too short (minimum #{
                      min_characters} characters).") \
          if !min_characters.nil? && query.length < min_characters

        options = {order_by: search_params.order_by,
                   page: search_params.page,
                   per_page: search_params.per_page}
        out = run(OpenStax::Accounts::SearchAccounts, query, options).outputs
        outputs[:total_count] = out[:total_count]

        if !max_items.nil? && outputs[:total_count] > max_items
          fatal_error(code: :too_many_items,
                      message: "The number of matches exceeded the allowed limit of #{
                        max_items} matches. Please refine your query and try again.")
        end

        outputs[:items] = out[:items].to_a
      end

    end
  end
end
