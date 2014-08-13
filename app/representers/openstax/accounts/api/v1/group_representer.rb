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

          collection :group_owners,
                     as: :owners,
                     class: GroupOwner,
                     decorator: GroupUserRepresenter,
                     writeable: false

          collection :group_members,
                     as: :members,
                     class: GroupMember,
                     decorator: GroupUserRepresenter,
                     writeable: false

          collection :group_nestings,
                     as: :groups,
                     class: GroupNesting,
                     decorator: GroupNestingRepresenter,
                     writeable: false

        end
      end
    end
  end
end
