module OpenStax
  module Accounts
    module Api
      module V1
        class AccountSearchRepresenter < OpenStax::Api::V1::AbstractSearchRepresenter

    property :total_count,
             inherit: true,
             schema_info: {
               description: "The number of users matching the query; can be more than the number returned"
             }

    collection :items,
               inherit: true,
               class: Account,
               decorator: Api::V1::AccountRepresenter,
               schema_info: {
                 description: "The users matching the query or a subset thereof when paginating"
               }

        end
      end
    end
  end
end
