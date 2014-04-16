module OpenStax
  module Accounts
    module Api
      module V1
        class UserSearchRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :num_matching_users,
                   type: Integer

          property :page,
                   type: Integer

          property :per_page,
                   type: Integer

          property :order_by,
                   type: String


          collection :users,
                     class: OpenStax::Accounts::User,
                     decorator: UserRepresenter

        end
      end
    end
  end
end
