class AddSchoolTypeToAccountsAccounts < ActiveRecord::Migration
  def change
    add_column :openstax_accounts_accounts, :school_type, :integer, null: false, default: 0
    add_index :openstax_accounts_accounts, :school_type
  end
end
