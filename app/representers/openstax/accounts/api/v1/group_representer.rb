module OpenStax
  module Accounts
    module Api
      module V1
        class GroupRepresenter < Roar::Decorator

          # This representer is used to communicate with Accounts
          # and so must allow read/write on all properties

          include Roar::JSON

          property :openstax_uid,
                   as: :id,
                   type: Integer,
                   schema_info: {
                     description: "The group's unique ID number",
                     required: true
                   }

          property :name,
                   type: String,
                   schema_info: {
                     description: "The group's name"
                   }

          property :is_public,
                   schema_info: {
                     type: "boolean",
                     description: "The group's visibility setting"
                   }

          collection :group_owners,
                     as: :owners,
                     class: GroupOwner,
                     decorator: GroupUserRepresenter,
                     schema_info: { description: "The owners of this group" }

          collection :group_members,
                     as: :members,
                     class: GroupMember,
                     decorator: GroupUserRepresenter,
                     schema_info: { description: "The direct members of this group" }

          collection :member_group_nestings,
                     as: :nestings,
                     class: GroupNesting,
                     decorator: GroupNestingRepresenter,
                     schema_info: { description: "The groups directly nested within this group" }

          property :cached_supertree_group_ids,
                   as: :supertree_group_ids,
                   type: Array,
                   schema_info: {
                     items: "integer",
                     description: "The ID's of all groups that should be updated if this group is changed; For caching purposes"
                   }

          property :cached_subtree_group_ids,
                   as: :subtree_group_ids,
                   type: Array,
                   schema_info: {
                     items: "integer",
                     description: "The ID's of all groups nested in this group's subtree, including this one; For caching purposes"
                   }

        end
      end
    end
  end
end
