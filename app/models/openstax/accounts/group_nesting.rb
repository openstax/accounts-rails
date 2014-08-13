module OpenStax::Accounts
  class GroupNesting < ActiveRecord::Base

    attr_accessor :requestor

    belongs_to :container_group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :member_group_nestings
    belongs_to :member_group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :container_group_nesting

    validates :openstax_uid, uniqueness: true, presence: true

    before_validation :create_openstax_accounts_group_nesting, :on => :create
    before_destroy :destroy_openstax_accounts_group_nesting

    def create_openstax_accounts_group_nesting
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.create_group_nesting(requestor, self)
    end

    def destroy_openstax_accounts_group_nesting
      return if OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.destroy_group_nesting(requestor, self)
    end

  end
end
