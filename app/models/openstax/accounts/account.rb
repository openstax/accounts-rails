module OpenStax
  module Accounts
    class Account < ActiveRecord::Base

      USERNAME_DISCARDED_CHAR_REGEX = /[^A-Za-z\d_]/
      USERNAME_MAX_LENGTH = 50

      attr_accessor :syncing_with_accounts

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
        false
      end

      def update_openstax_accounts
        return if syncing_with_accounts || \
                  OpenStax::Accounts.configuration.enable_stubbing?

        OpenStax::Accounts.user_update(self)
      end

    end
  end
end