require 'representable/json/collection'

module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationUsersRepresenter < Roar::Decorator
          include Representable::JSON::Collection

          items class: OpenStax::Accounts::ApplicationUser,
                decorator: ApplicationUserRepresenter
        end
      end
    end
  end
end
