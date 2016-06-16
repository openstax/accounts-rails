# A representer for Accounts
#
# This representer can be used directly or subclassed for an object that
# delegates openstax_uid, username, first_name, last_name, full_name and
# title to an account

module OpenStax
  module Accounts
    module Api
      module V1
        class AccountRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

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

        end
      end
    end
  end
end
