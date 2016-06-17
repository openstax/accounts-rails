module OpenStax
  module Accounts
    module Api
      module V1
        class GroupUserRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

          include Roar::JSON

          property :group_id,
                   type: Integer,
                   schema_info: {
                     required: true,
                     description: "The associated group's unique ID number"
                   }

          nested :user do
            property :user_id,
                     as: :id,
                     type: Integer,
                     schema_info: {
                       required: true,
                       description: "The associated user's unique ID number"
                     }
          end

        end
      end
    end
  end
end
