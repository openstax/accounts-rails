module OpenStax
  module Accounts
    class User < ActiveRecord::Base

      validates :username, uniqueness: true
      validates :username, presence: true
      validates :openstax_uid, presence: true

      # first and last names are not required

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