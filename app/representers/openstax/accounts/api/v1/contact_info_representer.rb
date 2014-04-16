module OpenStax
  module Accounts
    module Api
      module V1
        class ContactInfoRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :id, 
                   type: Integer

          property :type,
                   type: String

          property :value,
                   type: String

          property :verified

        end
      end
    end
  end
end
