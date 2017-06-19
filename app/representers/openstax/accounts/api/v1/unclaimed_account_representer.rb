module OpenStax
  module Accounts
    module Api
      module V1
        class UnclaimedAccountRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties
          # Do not use it in create/update APIs!

          include Roar::JSON

          property :id,
                   type: Integer,
                   schema_info: {
                     description: "The unclaimed account's unique ID number",
                     required: true
                   }

          property :uuid,
                   type: String,
                   schema_info: {
                     description: "The unclaimed account's UUID",
                     required: true
                   }

        end
      end
    end
  end
end
