class CreateOpenStaxAccountsAccounts < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_accounts do |t|
      t.integer :openstax_uid, :null => false
      t.string  :username, :null => false
      t.string  :first_name, :null => false, :default => ''
      t.string  :last_name, :null => false, :default => ''
      t.string  :full_name, :null => false, :default => ''
      t.string  :title, :null => false, :default => ''
      t.string  :access_token, :null => false, :default => ''

      t.timestamps
    end

    add_index :openstax_accounts_accounts, :openstax_uid, :unique => true
    add_index :openstax_accounts_accounts, :username, :unique => true
    add_index :openstax_accounts_accounts, :access_token, :unique => true
    add_index :openstax_accounts_accounts, :first_name
    add_index :openstax_accounts_accounts, :last_name
    add_index :openstax_accounts_accounts, :full_name
  end
end
