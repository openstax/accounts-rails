module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationAccountSearchRepresenter < AccountSearchRepresenter

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties
          # Do not use it in create/update APIs!

          collection :application_accounts,
                     as: :application_users,
                     class: OpenStax::Accounts::ApplicationAccount,
                     decorator: ApplicationAccountRepresenter,
                     schema_info: {
                       description: "The accounts of matching users that have used this app",
                       required: true,
                       minItems: 0
                     }

        end
      end
    end
  end
end
