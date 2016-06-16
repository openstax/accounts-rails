module OpenStax
  module Accounts
    module Api
      module V1
        class UnclaimedAccountRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

          include Roar::JSON

          property :id,
                   type: Integer,
                   schema_info: {
                     description: "The unclaimed account's unique ID number",
                     required: true
                   }

        end
      end
    end
  end
end
