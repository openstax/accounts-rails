module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationAccountRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

          include Roar::JSON

          property :id,
                   type: Integer,
                   schema_info: {
                     description: "A unique ID number for the record that associates this account with this application",
                     required: true
                   }

          property :application_id,
                   type: Integer,
                   schema_info: {
                     description: "The associated application's unique ID number",
                     required: true
                   }

          property :account,
                   as: :user,
                   instance: ->(*) do
                     OpenStax::Accounts::Account.new.tap{ |account| account.syncing = true }
                   end,
                   decorator: AccountRepresenter,
                   schema_info: {
                     description: "The associated account",
                     required: true
                   }

          property :unread_updates,
                   type: Integer,
                   schema_info: {
                     description: "The number of profile updates from the associated account unread by the associated application",
                     required: true
                   }

          property :default_contact_info_id,
                   type: Integer,
                   schema_info: {
                     description: "The ID of the associated account's default contact info"
                   }

        end
      end
    end
  end
end
