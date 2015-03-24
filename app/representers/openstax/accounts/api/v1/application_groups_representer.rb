module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationGroupsRepresenter < Roar::Decorator
          include Representable::JSON::Collection

          items class: OpenStax::Accounts::ApplicationGroup,
                decorator: ApplicationGroupRepresenter
        end
      end
    end
  end
end
