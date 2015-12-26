module OpenStax
  module Accounts
    module Dev
      class AccountsSearch < OpenStax::Accounts::AccountsSearch
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
          @min_characters = nil
          @max_items = nil
        end

        def authorized?
          !Rails.env.production?
        end

      end
    end
  end
end
