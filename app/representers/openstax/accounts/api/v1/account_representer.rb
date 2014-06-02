module OpenStax
  module Accounts
    module Api
      module V1
        class AccountRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :openstax_uid,
                   as: :id,
                   type: Integer

          property :username,
                   type: String

          property :first_name,
                   type: String

          property :last_name,
                   type: String

          property :full_name,
                   type: String

          property :title,
                   type: String

        end
      end
    end
  end
end
