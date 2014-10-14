module OpenStax
  module Accounts
    module Api
      module V1
        class AccountSearchRepresenter < OpenStax::Api::V1::AbstractSearchRepresenter

          property :total_count,
                   as: :num_matching_users,
                   writeable: true,
                   readable: true,
                   schema_info: {
                     description: "The number of accounts matching the query; can be more than the number returned"
                   }

          collection :items,
                     as: :users,
                     class: Account,
                     decorator: Api::V1::AccountRepresenter,
                     writeable: true,
                     readable: true,
                     schema_info: {
                       description: "The accounts matching the query or a subset thereof when paginating"
                     }

        end
      end
    end
  end
end
