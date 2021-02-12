require 'openstax_api'

module OpenStax
  module Accounts
    module Api
      module V1
        class AccountSearchRepresenter < OpenStax::Api::V1::AbstractSearchRepresenter

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties
          # Do not use it in create/update APIs!

          property :total_count,
                   inherit: true,
                   schema_info: {
                     description: "The number of accounts matching the query; can be more than the number returned",
                     required: true
                   }

          collection :items,
                     inherit: true,
                     class: Account,
                     decorator: Api::V1::AccountRepresenter,
                     schema_info: {
                       description: "The accounts matching the query or a subset thereof when paginating",
                       required: true
                     }

        end
      end
    end
  end
end
