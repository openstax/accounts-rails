module OpenStax
  module Accounts
    module Dev
      class AccountsSearch < OpenStax::Accounts::AccountsSearch

        self.min_characters = nil
        self.max_items = nil

        paramify :search do
          attribute :type, type: String
          attribute :q, type: String
          attribute :order_by, type: String
          attribute :page, type: Integer
          attribute :per_page, type: Integer
        end

        protected

        def authorized?
          !Rails.env.production?
        end

      end
    end
  end
end
