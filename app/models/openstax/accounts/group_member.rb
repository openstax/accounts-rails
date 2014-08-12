module OpenStax::Accounts
  class GroupMember < ActiveRecord::Base
    validates :openstax_uid, uniqueness: true, presence: true
  end
end
