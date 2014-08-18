module OpenStax
  module Accounts
    module Api
      module V1
        class GroupNestingRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :container_group_id,
                   type: Integer

          property :member_group_id,
                   type: Integer

        end
      end
    end
  end
end
