module OpenStax::Accounts
  class GroupOwner < ActiveRecord::Base

    delegate :requestor, :syncing, to: :group

    belongs_to :group, class_name: 'OpenStax::Accounts::Group',
               primary_key: :openstax_uid, inverse_of: :group_owners
    belongs_to :user, class_name: 'OpenStax::Accounts::Account',
               primary_key: :openstax_uid, inverse_of: :group_owners

    validates :group, presence: true
    validates :user, presence: true, uniqueness: { scope: :group }
    validates :requestor, presence: true, unless: :syncing_or_stubbing

    before_create :create_openstax_accounts_group_owner, unless: :syncing_or_stubbing
    before_destroy :destroy_openstax_accounts_group_owner, unless: :syncing_or_stubbing

    protected

    def syncing_or_stubbing
      syncing || OpenStax::Accounts.configuration.enable_stubbing?
    end

    def create_openstax_accounts_group_owner
      return false if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.create_group_owner(requestor, self) if requestor.has_authenticated?
    end

    def destroy_openstax_accounts_group_owner
      return false if requestor.nil? || requestor.is_anonymous?

      OpenStax::Accounts::Api.destroy_group_owner(requestor, self) if requestor.has_authenticated?
    end

  end
end
