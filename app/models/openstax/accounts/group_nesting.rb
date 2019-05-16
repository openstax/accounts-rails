module OpenStax::Accounts
  class GroupNesting < ActiveRecord::Base

    delegate :requestor, :syncing, to: :container_group

    belongs_to :container_group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :member_group_nestings
    belongs_to :member_group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :container_group_nesting

    validates :container_group, presence: true
    validates :member_group, presence: true, uniqueness: true
    validates :requestor, presence: true, unless: :syncing_or_stubbing?
    validate :no_loops, unless: :syncing_or_stubbing?

    before_create :update_group_caches, unless: :syncing
    before_destroy :update_group_caches, unless: :syncing

    before_create :create_openstax_accounts_group_nesting, unless: :syncing_or_stubbing?
    before_destroy :destroy_openstax_accounts_group_nesting, unless: :syncing_or_stubbing?

    protected

    def syncing_or_stubbing?
      syncing || OpenStax::Accounts.configuration.enable_stubbing?
    end

    def no_loops
      return if member_group.nil? || !member_group.subtree_group_ids.include?(container_group_id)

      errors.add(:base, 'would create a loop') if errors[:base].blank?
      throw :abort
    end

    def update_group_caches
      UpdateGroupCaches.call(self)

      throw(:abort) if errors.any?
    end

    def create_openstax_accounts_group_nesting
      throw(:abort) if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.create_group_nesting(requestor, self) if requestor.has_authenticated?
    end

    def destroy_openstax_accounts_group_nesting
      throw(:abort) if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.destroy_group_nesting(requestor, self) \
        if requestor.has_authenticated?
    end

  end
end
