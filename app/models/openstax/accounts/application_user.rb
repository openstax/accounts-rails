module OpenStax
  module Accounts
    class ApplicationUser
      attr_accessor :id, :application_id, :user, :unread_updates, :default_contact_info_id
    end
  end
end
