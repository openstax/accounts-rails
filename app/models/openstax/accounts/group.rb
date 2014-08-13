module OpenStax::Accounts
  class Group < ActiveRecord::Base

    attr_accessor :requestor

    has_many :group_owners, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupOwner',
             primary_key: :openstax_uid, inverse_of: :group
    has_many :owners, through: :group_owners, source: :user

    has_many :group_members, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupMember',
             primary_key: :openstax_uid, inverse_of: :group
    has_many :members, through: :group_members, source: :user

    has_one :container_group_nesting, dependent: :destroy,
            class_name: 'OpenStax::Accounts::GroupNesting', primary_key: :openstax_uid,
            foreign_key: :member_group_id, inverse_of: :member_group
    has_one :container_group, through: :container_group_nesting

    has_many :member_group_nestings, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupNesting', primary_key: :openstax_uid,
             foreign_key: :container_group_id, inverse_of: :container_group
    has_many :member_groups, through: :member_group_nestings

    validates :openstax_uid, uniqueness: true, presence: true

    before_validation :create_openstax_accounts_group, :on => :create
    before_update :update_openstax_accounts_group
    before_destroy :destroy_openstax_accounts_group

    def create_openstax_accounts_group
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.create_group(requestor, self)
    end

    def update_openstax_accounts_group
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.update_group(requestor, self)
    end

    def destroy_openstax_accounts_group
      return if OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.destroy_group(requestor, self)
    end

  end
end
