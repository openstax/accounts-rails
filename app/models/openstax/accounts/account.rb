module OpenStax::Accounts
    class Account < ActiveRecord::Base

    USERNAME_DISCARDED_CHAR_REGEX = /[^A-Za-z\d_]/
    USERNAME_MAX_LENGTH = 50

    attr_accessor :syncing

    has_many :group_owners, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupOwner',
             primary_key: :openstax_uid,
             foreign_key: :user_id,
             inverse_of: :user
    has_many :groups_as_owner, through: :group_owners, source: :group

    has_many :group_members, dependent: :destroy,
             class_name: 'OpenStax::Accounts::GroupMember',
             primary_key: :openstax_uid,
             foreign_key: :user_id,
             inverse_of: :user
    has_many :groups_as_member, through: :group_members, source: :group

    enum faculty_status: [:no_faculty_info, :pending_faculty, :confirmed_faculty, :rejected_faculty]
    after_initialize { self.faculty_status ||= :no_faculty_info }
    validates :faculty_status, presence: true

    validates :openstax_uid, :presence => true, :uniqueness => true
    validates :username, :presence => true, :uniqueness => true,
                         :unless => :syncing_or_stubbing

    before_update :update_openstax_accounts, :unless => :syncing_or_stubbing

    def name
      (first_name || last_name) ? [first_name, last_name].compact.join(" ") : username
    end

    def casual_name
      first_name || username
    end

    def is_anonymous?
      false
    end

    def has_authenticated?
      !access_token.nil?
    end

    protected

    def syncing_or_stubbing
      syncing || OpenStax::Accounts.configuration.enable_stubbing?
    end

    def update_openstax_accounts
      OpenStax::Accounts::Api.update_account(self)
    end

  end
end
