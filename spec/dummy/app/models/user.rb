class User < ActiveRecord::Base
  belongs_to :account, class_name: 'OpenStax::Accounts::Account'

  delegate :username, :first_name, :last_name, :full_name, :title, :name, :casual_name, to: :account

  def is_anonymous?
    false
  end

  # OpenStax Accounts "account_user_mapper" methods

  def self.account_to_user(acc)
    raise ArgumentError, 'Account is nil', caller if acc.nil?

    acc.is_anonymous? ? AnonymousUser.instance : where(account_id: acc.id).first
  end

  def self.user_to_account(user)
    raise ArgumentError, 'User is nil', caller if user.nil?

    user.is_anonymous? ? AnonymousAccount.instance : user.account
  end
end
