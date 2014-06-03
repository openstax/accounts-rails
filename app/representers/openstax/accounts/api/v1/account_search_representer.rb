module OpenStax
  module Accounts
    module Api
      module V1
        class AccountSearchRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :num_matching_accounts,
                   type: Integer

          property :page,
                   type: Integer

          property :per_page,
                   type: Integer

          property :order_by,
                   type: String

          collection :accounts,
                     class: Account,
                     decorator: AccountRepresenter

        end
      end
    end
  end
end
