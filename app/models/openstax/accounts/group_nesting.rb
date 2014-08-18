module OpenStax::Accounts
  class GroupNesting < ActiveRecord::Base

    attr_accessor :requestor

    belongs_to :container_group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :member_group_nestings
    belongs_to :member_group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :container_group_nesting

    validates_presence_of :container_group_id, :member_group_id
    validates_uniqueness_of :member_group_id
    validates_presence_of :container_group, :member_group, :requestor,
                          :unless => :syncing_or_stubbing
    validate :no_loops, :unless => :syncing_or_stubbing

    before_create :update_group_caches, :create_openstax_accounts_group_nesting,
                  :unless => :syncing_or_stubbing
    before_destroy :update_group_caches, :destroy_openstax_accounts_group_nesting,
                   :unless => :syncing_or_stubbing

    protected

    def syncing_or_stubbing
      OpenStax::Accounts.syncing ||\
      OpenStax::Accounts.configuration.enable_stubbing?
    end

    def no_loops
      return if member_group.nil? ||\
                !member_group.subtree_group_ids.include?(container_group_id)
      errors.add(:base, 'would create a loop') if errors[:base].blank?
      false
    end

    def update_group_caches
      # Returns false if the update fails (aborting the save transaction)
      UpdateGroupCaches.call(self).errors.none?
    end

    def create_openstax_accounts_group_nesting
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.create_group_nesting(requestor, self)
    end

    def destroy_openstax_accounts_group_nesting
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.destroy_group_nesting(requestor, self)
    end

  end
end
