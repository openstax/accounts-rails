module OpenStax
  module Accounts
    module Api
      module V1
        class AccountSearchRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :num_matching_accounts,
                   as: :num_matching_users,
                   type: Integer

          property :page,
                   type: Integer

          property :per_page,
                   type: Integer

          property :order_by,
                   type: String

          collection :accounts,
                     as: :users,
                     class: Account,
                     decorator: AccountRepresenter

        end
      end
    end
  end
end
