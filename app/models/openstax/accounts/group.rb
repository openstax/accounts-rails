module OpenStax::Accounts
  class Group < ActiveRecord::Base
    validates :openstax_uid, uniqueness: true, presence: true
  end
end
