module OpenStax
  module Accounts
    module Api
      module V1
        class GroupNestingRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

          include Roar::JSON

          property :container_group_id,
                   type: Integer,
                   schema_info: {
                     description: "The unique ID number of the associated containing group",
                     required: true
                   }

          property :member_group_id,
                   type: Integer,
                   schema_info: {
                     description: "The unique ID number of the associated contained group",
                     required: true
                   }

        end
      end
    end
  end
end
