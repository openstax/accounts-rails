class User < ActiveRecord::Base
  belongs_to :openstax_accounts_account, 
             class_name: "OpenStax::Accounts::Account",
             dependent: :destroy

  delegate :username, :first_name, :last_name, :full_name, :title,
           :name, :casual_name, to: :openstax_accounts_account

  def is_anonymous?
    false
  end

  # OpenStax Accounts "account_user_mapper" methods

  def self.account_to_user(account)
    account.is_anonymous? ? \
      AnonymousUser.instance : \
      User.where(:openstax_accounts_account_id => account.id).first
  end

  def self.user_to_account(user)
    user.is_anonymous? ? \
      AnonymousAccount.instance : \
      user.openstax_accounts_account
  end
end
