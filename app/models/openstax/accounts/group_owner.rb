module OpenStax::Accounts
  class GroupOwner < ActiveRecord::Base
    validates :openstax_uid, uniqueness: true, presence: true
  end
end
