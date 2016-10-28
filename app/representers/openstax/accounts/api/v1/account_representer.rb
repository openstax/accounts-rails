# A representer for Accounts

module OpenStax
  module Accounts
    module Api
      module V1
        class AccountRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties
          # Do not use it in create/update APIs!

          # Otherwise, this representer can be used directly or subclassed
          # for an object that delegates openstax_uid, username, first_name, last_name, full_name, # title, faculty_status and salesforce_contact_id to an account

          include Roar::JSON

          property :openstax_uid,
                   as: :id,
                   type: Integer,
                   schema_info: {
                     description: "The account's unique ID number",
                     required: true
                   }

          property :username,
                   type: String,
                   schema_info: {
                     description: "The account's unique username (case insensitive)",
                     required: true
                   }

          property :first_name,
                   type: String,
                   schema_info: {
                     description: "The user's first name"
                   }

          property :last_name,
                   type: String,
                   schema_info: {
                     description: "The user's last name"
                   }

          property :full_name,
                   type: String,
                   schema_info: {
                     description: "The user's full name"
                   }

          property :title,
                   type: String,
                   schema_info: {
                     description: "The user's title"
                   }

          property :salesforce_contact_id,
                   type: String,
                   schema_info: {
                     description: "The user's salesforce contact id"
                   }

          property :faculty_status,
                   type: String,
                   schema_info: {
                     description: "One of #{
                       OpenStax::Accounts::Account.faculty_statuses.keys.map(&:to_s).inspect
                     }"
                   }

        end
      end
    end
  end
end
