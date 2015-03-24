module OpenStax
  module Accounts
    module Api
      module V1
        class GroupUserRepresenter < Roar::Decorator
          include Roar::JSON

          property :group_id,
                   type: Integer

          nested :user do
            property :user_id,
                     as: :id,
                     type: Integer
          end

        end
      end
    end
  end
end
