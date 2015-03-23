module OpenStax
  module Accounts
    class Api
      module V1
        class ApplicationAccountSearchRepresenter < AccountSearchRepresenter

          collection :application_accounts,
                     as: :application_users,
                     class: OpenStax::Accounts::ApplicationAccount,
                     decorator: ApplicationAccountRepresenter,
                     writeable: true,
                     readable: true,
                     schema_info: {
                       description: "The accounts of matching users that have used this app",
                       minItems: 0
                     }

        end
      end
    end
  end
end
