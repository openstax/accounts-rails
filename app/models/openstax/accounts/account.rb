module OpenStax::Accounts
    class Account < ActiveRecord::Base

    USERNAME_DISCARDED_CHAR_REGEX = /[^A-Za-z\d_]/
    USERNAME_MAX_LENGTH = 50
    SYNC_ATTRIBUTES = [
      :username,
      :first_name,
      :last_name,
      :full_name,
      :title,
      :self_reported_role,
      :faculty_status,
      :school_type,
      :salesforce_contact_id,
      :uuid,
      :support_identifier,
      :is_test
    ]

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
    enum role: [
      :unknown_role,
      :student,
      :instructor,
      :administrator,
      :librarian,
      :designer,
      :other,
      :adjunct,
      :homeschool
    ]
    enum school_type: [:unknown_school_type, :other_school_type, :college]

    validates :faculty_status, :role, :school_type, presence: true

    validates :openstax_uid, uniqueness: { allow_nil: true }
    validates :username, uniqueness: { allow_nil: true }
    validates :uuid, presence: true, uniqueness: true
    validates :support_identifier, uniqueness: { allow_nil: true }

    before_update :update_openstax_accounts, if: :should_send_updates_to_accounts?

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

    def valid_openstax_uid?
      !openstax_uid.nil? && openstax_uid > 0
    end

    def self_reported_role
      role
    end

    def self_reported_role=(role)
      self.role = role
    end

    protected

    def syncing_or_stubbing?
      syncing || OpenStax::Accounts.configuration.enable_stubbing?
    end

    def should_send_updates_to_accounts?
      !syncing_or_stubbing? && valid_openstax_uid?
    end

    def update_openstax_accounts
      OpenStax::Accounts::Api.update_account(self)
    end

  end
end
