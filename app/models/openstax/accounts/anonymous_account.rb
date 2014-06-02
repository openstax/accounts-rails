module OpenStax
  module Accounts
    class AnonymousAccount < Account

      include Singleton

      before_save { false }

      def initialize(attributes=nil)
        super
        self.openstax_uid = nil
        self.first_name   = 'Guest'
        self.last_name    = 'User'
      end

      def is_anonymous?
        true
      end

    end
  end
end