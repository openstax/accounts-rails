module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationAccountsRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties
          # Do not use it in create/update APIs!

          include Representable::JSON::Collection

          items class: OpenStax::Accounts::ApplicationAccount,
                decorator: ApplicationAccountRepresenter

        end
      end
    end
  end
end
