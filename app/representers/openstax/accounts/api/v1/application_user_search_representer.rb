module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationUserSearchRepresenter < UserSearchRepresenter

          collection :application_users,
                     class: OpenStax::Accounts::ApplicationUser,
                     decorator: ApplicationUserRepresenter,
                     schema_info: {
                       description: "The ApplicationUsers associated with the matching Users",
                       minItems: 0
                     }

        end
      end
    end
  end
end
