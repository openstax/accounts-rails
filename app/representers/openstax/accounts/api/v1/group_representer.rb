module OpenStax
  module Accounts
    class Api
      module V1
        class GroupRepresenter < Roar::Decorator
          include Roar::JSON

          property :openstax_uid,
                   as: :id,
                   type: Integer

          property :name,
                   type: String

          property :is_public

          collection :group_owners,
                     as: :owners,
                     class: GroupOwner,
                     decorator: GroupUserRepresenter

          collection :group_members,
                     as: :members,
                     class: GroupMember,
                     decorator: GroupUserRepresenter

          collection :member_group_nestings,
                     as: :nestings,
                     class: GroupNesting,
                     decorator: GroupNestingRepresenter

          property :cached_supertree_group_ids,
                   as: :supertree_group_ids,
                   type: Array,
                   schema_info: {
                     items: "integer"
                   }

          property :cached_subtree_group_ids,
                   as: :subtree_group_ids,
                   type: Array,
                   schema_info: {
                     items: "integer"
                   }

        end
      end
    end
  end
end
