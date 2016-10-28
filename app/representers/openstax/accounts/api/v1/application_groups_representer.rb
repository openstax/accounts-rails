module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationGroupsRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties
          # Do not use it in create/update APIs!

          include Representable::JSON::Collection

          items class: OpenStax::Accounts::ApplicationGroup,
                decorator: ApplicationGroupRepresenter

        end
      end
    end
  end
end
