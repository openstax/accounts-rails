module OpenStax::Accounts
  class Group < ActiveRecord::Base

    serialize :cached_supertree_group_ids
    serialize :cached_subtree_group_ids

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

    validates :openstax_uid, :uniqueness => true, :presence => true
    validates_presence_of :requestor, :unless => :syncing_or_stubbing
    validates_uniqueness_of :name, :allow_nil => true, :unless => :syncing_or_stubbing

    before_validation :create_openstax_accounts_group,
                      :on => :create, :unless => :syncing_or_stubbing
    before_update :update_openstax_accounts_group, :unless => :syncing_or_stubbing
    before_destroy :destroy_openstax_accounts_group, :unless => :syncing_or_stubbing

    scope :visible_for, lambda { |account|
      next where(is_public: true) unless account.is_a? OpenStax::Accounts::Account

      includes(:group_members).includes(:group_owners)
      .where{((is_public.eq true) |\
               (group_members.user_id.eq my{account.id}) |\
               (group_owners.user_id.eq my{account.id}))}
    }

    def has_owner?(account)
      return false unless account.is_a? OpenStax::Accounts::Account
      !group_owners.where(user_id: account.id).first.nil?
    end

    def has_direct_member?(account)
      return false unless account.is_a? OpenStax::Accounts::Account
      !group_members.where(user_id: account.id).first.nil?
    end

    def has_member?(account)
      return false unless account.is_a? OpenStax::Accounts::Account
      !account.group_members.where(group_id: subtree_group_ids).first.nil?
    end

    def add_owner(account)
      return false unless account.is_a? OpenStax::Accounts::Account
      go = GroupOwner.new
      go.group = self
      go.user = account
      return false unless go.valid?
      go.save if persisted?
      group_owners << go
    end

    def add_member(account)
      return false unless account.is_a? OpenStax::Accounts::Account
      gm = GroupMember.new
      gm.group = self
      gm.user = account
      return false unless gm.valid?
      gm.save if persisted?
      group_members << gm
    end

    def supertree_group_ids
      return cached_supertree_group_ids unless cached_supertree_group_ids.nil?
      return [] unless persisted?
      reload

      gids = [id] + (Group.includes(:member_group_nestings)
                          .where(member_group_nestings: {member_group_id: id})
                          .first.try(:supertree_group_ids) || [])
      update_column(:cached_supertree_group_ids, gids.to_yaml)
      self.cached_supertree_group_ids = gids
    end

    def subtree_group_ids
      return cached_subtree_group_ids unless cached_subtree_group_ids.nil?
      return [] unless persisted?
      reload

      gids = [id] + Group.includes(:container_group_nesting)
                         .where(container_group_nesting: {container_group_id: id})
                         .collect{|g| g.subtree_group_ids}.flatten
      update_column(:cached_subtree_group_ids, gids.to_yaml)
      self.cached_subtree_group_ids = gids
    end

    protected

    def syncing_or_stubbing
      OpenStax::Accounts.syncing ||\
      OpenStax::Accounts.configuration.enable_stubbing?
    end

    def create_openstax_accounts_group
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?

      OpenStax::Accounts.create_group(requestor, self)
    end

    def update_openstax_accounts_group
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?

      OpenStax::Accounts.update_group(requestor, self)
    end

    def destroy_openstax_accounts_group
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?

      OpenStax::Accounts.destroy_group(requestor, self)
    end

  end
end
