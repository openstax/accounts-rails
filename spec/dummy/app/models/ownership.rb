class Ownership < ActiveRecord::Base

  belongs_to :owner, polymorphic: true

  validates :owner, presence: true

end
