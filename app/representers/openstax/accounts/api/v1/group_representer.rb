module OpenStax
  module Accounts
    module Api
      module V1
        class GroupRepresenter < Roar::Decorator
          include Roar::Representer::JSON

          property :openstax_uid,
                   as: :id,
                   type: Integer

          property :name,
                   type: String

          property :is_public

          collection :owners,
                     class: GroupOwner,
                     decorator: GroupUserRepresenter,
                     writeable: false,
                     parse_strategy: :sync

          collection :members,
                     class: GroupMember,
                     decorator: GroupUserRepresenter,
                     writeable: false,
                     parse_strategy: :sync

          collection :groups,
                     class: GroupNesting,
                     decorator: GroupNestingRepresenter,
                     writeable: false,
                     parse_strategy: :sync

        end
      end
    end
  end
end
