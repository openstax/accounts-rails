class CreateOpenStaxAccountsGroupMembers < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_group_members do |t|
      t.integer :openstax_uid, :null => false
      t.references :group, null: false
      t.references :user, null: false

      t.timestamps
    end

    add_index :openstax_accounts_group_members, :openstax_uid, :unique => true
    add_index :openstax_accounts_group_members, [:group_id, :user_id], unique: true
    add_index :openstax_accounts_group_members, :user_id
  end
end
