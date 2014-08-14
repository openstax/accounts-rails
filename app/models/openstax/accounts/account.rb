module OpenStax::Accounts
    class Account < ActiveRecord::Base

    USERNAME_DISCARDED_CHAR_REGEX = /[^A-Za-z\d_]/
    USERNAME_MAX_LENGTH = 50

    has_many :group_owners, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupOwner',
             primary_key: :openstax_uid, foreign_key: :user_id, inverse_of: :user
    has_many :owned_groups, through: :group_owners, source: :group

    has_many :group_members, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupMember',
             primary_key: :openstax_uid, foreign_key: :user_id, inverse_of: :user
    has_many :member_groups, through: :group_members, source: :group

    validates :username, uniqueness: true, presence: true
    validates :openstax_uid, uniqueness: true, presence: true
    validates :access_token, uniqueness: true, allow_nil: true

    before_update :update_openstax_accounts

    def name
      (first_name || last_name) ? [first_name, last_name].compact.join(" ") : username
    end

    def casual_name
      first_name || username
    end    

    def is_anonymous?
      false
    end

    def update_openstax_accounts
      return if OpenStax::Accounts.syncing || OpenStax::Accounts.configuration.enable_stubbing?

      OpenStax::Accounts.update_account(self)
    end

  end
end