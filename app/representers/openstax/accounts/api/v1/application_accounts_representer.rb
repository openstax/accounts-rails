module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationAccountsRepresenter < Roar::Decorator
          include Representable::JSON::Collection

          items class: OpenStax::Accounts::ApplicationAccount,
                decorator: ApplicationAccountRepresenter
        end
      end
    end
  end
end
