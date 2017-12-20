class AddSupportIdentifierToAccountsAccounts < ActiveRecord::Migration
  def change
    enable_extension :citext

    add_column :openstax_accounts_accounts, :support_identifier, :citext
    add_index :openstax_accounts_accounts, :support_identifier, unique: true
  end
end