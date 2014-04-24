module OpenStax
  module Accounts
    module Api
      module V1
        class UserRepresenter < Roar::Decorator
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

# TODO: Not yet implemented in this gem
#          collection :contact_infos,
#                     class: OpenStax::Accounts::ContactInfo,
#                     decorator: ContactInfoRepresenter

        end
      end
    end
  end
end
