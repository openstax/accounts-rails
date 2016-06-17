module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationGroupRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

          include Roar::JSON

          property :id,
                   type: Integer,
                   schema_info: {
                     description: "A unique ID number for the record that associates this group with this application",
                     required: true
                   }

          property :application_id,
                   type: Integer,
                   schema_info: {
                     description: "The associated application's unique ID number",
                     required: true
                   }

          property :group,
                   instance: ->(*) do
                     OpenStax::Accounts::Group.new.tap{ |group| group.syncing = true }
                   end,
                   decorator: GroupRepresenter,
                   schema_info: {
                     description: "The associated group",
                     required: true
                   }

          property :unread_updates,
                   type: Integer,
                   schema_info: {
                     description: "The number of updates applied to the associated group unread by the associated application",
                     required: true
                   }

        end
      end
    end
  end
end
