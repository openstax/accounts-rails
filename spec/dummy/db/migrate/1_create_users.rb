class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :openstax_accounts_account_id

      t.timestamps
    end

    add_index :users, :openstax_accounts_account_id, :unique => true
  end
end
