module OpenStax
  module Accounts
    class User < ActiveRecord::Base

      USERNAME_DISCARDED_CHAR_REGEX = /[^A-Za-z\d_]/
      USERNAME_MAX_LENGTH = 50

      attr_accessor :updating_from_accounts

      validates :username, uniqueness: true, presence: true
      validates :openstax_uid, presence: true

      attr_accessible :username, :first_name, :last_name, :full_name, :title

      before_update :update_openstax_accounts

      def name
        (first_name || last_name) ? [first_name, last_name].compact.join(" ") : username
      end

      def casual_name
        first_name || username
      end    

      def is_anonymous?
        is_anonymous == true
      end

      attr_accessor :is_anonymous

      def self.anonymous
        @@anonymous ||= AnonymousUser.new
      end

      def update_openstax_accounts
        return if updating_from_accounts || \
                  OpenStax::Accounts.configuration.enable_stubbing?
        OpenStax::Accounts.user_update(self)
      end

      class AnonymousUser < User
        before_save { false } 
        def initialize(attributes=nil)
          super
          self.is_anonymous = true
          self.first_name   = 'Guest'
          self.last_name    = 'User'
          self.openstax_uid = nil
        end
      end

    end
  end
end