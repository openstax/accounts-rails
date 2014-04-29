require 'representable/json/collection'

module OpenStax
  module Accounts
    module Api
      module V1
        class ApplicationUsersRepresenter < Roar::Decorator
          include Representable::JSON::Collection

          items class: ApplicationUser, decorator: ApplicationUserRepresenter
        end
      end
    end
  end
end
