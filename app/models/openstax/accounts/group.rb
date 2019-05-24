module OpenStax::Accounts
  class Group < ActiveRecord::Base

    serialize :cached_supertree_group_ids
    serialize :cached_subtree_group_ids

    attr_accessor :requestor, :syncing

    has_many :group_owners, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupOwner',
             primary_key: :openstax_uid, inverse_of: :group
    has_many :owners, through: :group_owners, source: :user

    has_many :group_members, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupMember',
             primary_key: :openstax_uid,
             inverse_of: :group
    has_many :members, through: :group_members, source: :user

    has_one :container_group_nesting, dependent: :destroy,
            class_name: 'OpenStax::Accounts::GroupNesting',
            primary_key: :openstax_uid,
            foreign_key: :member_group_id,
            inverse_of: :member_group
    has_one :container_group, through: :container_group_nesting

    has_many :member_group_nestings,
             class_name: 'OpenStax::Accounts::GroupNesting',
             primary_key: :openstax_uid,
             foreign_key: :container_group_id,
             dependent: :destroy,
             inverse_of: :container_group
    has_many :member_groups, through: :member_group_nestings

    validates :openstax_uid, uniqueness: true, presence: true
    validates_presence_of :requestor, unless: :syncing_or_stubbing?
    validates_uniqueness_of :name, allow_nil: true, unless: :syncing_or_stubbing?

    before_validation :create_openstax_accounts_group, on: :create, unless: :syncing_or_stubbing?
    before_update :update_openstax_accounts_group, unless: :syncing_or_stubbing?
    before_destroy :destroy_openstax_accounts_group, unless: :syncing_or_stubbing?

    scope(
      :visible_for, ->(account) do
        next where(is_public: true) unless account.is_a? OpenStax::Accounts::Account

        groups = arel_table
        group_members = OpenStax::Accounts::GroupMember.arel_table
        group_owners = OpenStax::Accounts::GroupOwner.arel_table

        where(
          groups[:is_public].eq(true).or(
            OpenStax::Accounts::GroupMember.where(
              group_members[:group_id].eq(groups[:openstax_uid]).and(
                group_members[:user_id].eq(account.id)
              )
            ).exists
          ).or(
            OpenStax::Accounts::GroupOwner.where(
              group_owners[:group_id].eq(groups[:openstax_uid]).and(
                group_owners[:user_id].eq(account.id)
              )
            ).exists
          )
        )
      end
    )

    def has_owner?(account)
      return false unless account.is_a? OpenStax::Accounts::Account

      gos = group_owners
      gos = gos.preload(:user) if persisted?
      gos.any?{ |go| go.user == account }
    end

    def has_direct_member?(account)
      return false unless account.is_a? OpenStax::Accounts::Account

      gms = group_members
      gms = gms.preload(:user) if persisted?
      gms.any?{ |gm| gm.user == account }
    end

    def has_member?(account)
      return false unless account.is_a? OpenStax::Accounts::Account
      !account.group_members.where(group_id: subtree_group_ids).first.nil?
    end

    def add_owner(account)
      return unless account.is_a? OpenStax::Accounts::Account
      go = GroupOwner.new
      go.group = self
      go.user = account
      return unless go.valid?
      go.save if persisted?
      group_owners << go
      go
    end

    def add_member(account)
      return unless account.is_a? OpenStax::Accounts::Account
      gm = GroupMember.new
      gm.group = self
      gm.user = account
      return unless gm.valid?
      gm.save if persisted?
      group_members << gm
      gm
    end

    def supertree_group_ids
      return cached_supertree_group_ids unless cached_supertree_group_ids.nil?
      return [] unless persisted?
      reload

      gids = [openstax_uid] + (
        self.class.joins(:member_group_nestings).where(
          # This could have been:
          # member_group_nestings: { member_group_id: openstax_uid }
          # However that needs a monkeypatch to work in Rails 5 so we currently do this:
          openstax_accounts_group_nestings: { member_group_id: openstax_uid }
        ).first.try!(:supertree_group_ids) || []
      )
      update_column(:cached_supertree_group_ids, gids)
      self.cached_supertree_group_ids = gids
    end

    def subtree_group_ids
      return cached_subtree_group_ids unless cached_subtree_group_ids.nil?
      return [] unless persisted?
      reload

      gids = [openstax_uid] + self.class.joins(:container_group_nesting).where(
        # This could have been:
        # container_group_nesting: { container_group_id: openstax_uid }
        # However that needs a monkeypatch to work in Rails 5 so we currently do this:
        openstax_accounts_group_nestings: { container_group_id: openstax_uid }
      ).map { |group| group.subtree_group_ids }.flatten
      update_column(:cached_subtree_group_ids, gids)
      self.cached_subtree_group_ids = gids
    end

    protected

    def syncing_or_stubbing?
      syncing || OpenStax::Accounts.configuration.enable_stubbing?
    end

    def create_openstax_accounts_group
      return false if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.create_group(requestor, self) if requestor.has_authenticated?
    end

    def update_openstax_accounts_group
      return false if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.update_group(requestor, self) if requestor.has_authenticated?
    end

    def destroy_openstax_accounts_group
      return false if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.destroy_group(requestor, self) if requestor.has_authenticated?
    end

  end
end
