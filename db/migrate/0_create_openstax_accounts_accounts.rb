class CreateOpenStaxAccountsAccounts < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_accounts do |t|
      t.integer :openstax_uid
      t.string  :username
      t.string  :first_name
      t.string  :last_name
      t.string  :full_name
      t.string  :title
      t.string  :access_token

      t.timestamps
    end

    add_index :openstax_accounts_account, :openstax_uid, :unique => true
    add_index :openstax_accounts_account, :username, :unique => true
    add_index :openstax_accounts_account, :first_name
    add_index :openstax_accounts_account, :last_name
    add_index :openstax_accounts_account, :full_name
  end
end
