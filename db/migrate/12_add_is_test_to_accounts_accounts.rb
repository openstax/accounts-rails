class AddIsTestToAccountsAccounts < ActiveRecord::Migration
  def change
    add_column :openstax_accounts_accounts, :is_test, :boolean
  end
end
