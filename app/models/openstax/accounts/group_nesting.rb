module OpenStax::Accounts
  class GroupNesting < ActiveRecord::Base
    validates :openstax_uid, uniqueness: true, presence: true
  end
end
