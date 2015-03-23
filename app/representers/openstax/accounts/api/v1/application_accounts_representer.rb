require 'representable/json/collection'

module OpenStax
  module Accounts
    class Api
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
