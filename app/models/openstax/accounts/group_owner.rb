module OpenStax::Accounts
  class GroupOwner < ActiveRecord::Base

    attr_accessor :requestor

    belongs_to :group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :group_owners
    belongs_to :user, class_name: 'OpenStax::Accounts::Account',
               primary_key: :openstax_uid, inverse_of: :group_owners

    validates :openstax_uid, uniqueness: true, presence: true

    before_validation :create_openstax_accounts_group_owner, :on => :create
    before_destroy :destroy_openstax_accounts_group_owner

    def create_openstax_accounts_group_owner
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.create_group_owner(requestor, self)
    end

    def destroy_openstax_accounts_group_owner
      return if OpenStax::Accounts.configuration.enable_stubbing?
      return false unless requestor

      OpenStax::Accounts.destroy_group_owner(requestor, self)
    end

  end
end
