module OpenStax::Accounts
    class Account < ActiveRecord::Base
    USERNAME_DISCARDED_CHAR_REGEX = /[^A-Za-z\d_]/
    USERNAME_MAX_LENGTH = 50
    SYNC_ATTRIBUTES = [
      :openstax_uid,
      :username,
      :first_name,
      :last_name,
      :full_name,
      :title,
      :self_reported_role,
      :faculty_status,
      :school_type,
      :school_location,
      :salesforce_contact_id,
      :support_identifier,
      :is_test,
      :is_kip
    ]

    attr_accessor :syncing

    enum faculty_status: [
      :no_faculty_info,
      :pending_faculty,
      :confirmed_faculty,
      :rejected_faculty
    ]

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

    enum school_type: [
      :unknown_school_type,
      :other_school_type,
      :college,
      :high_school,
      :k12_school,
      :home_school
    ]

    enum school_location: [
      :unknown_school_location,
      :domestic_school,
      :foreign_school
    ]

    validates :faculty_status, :role, :school_type, :school_location, presence: true

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
