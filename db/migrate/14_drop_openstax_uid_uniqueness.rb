class DropOpenStaxUidUniqueness < ActiveRecord::Migration[5.2]
  def change
    remove_index :openstax_accounts_accounts, column: [ :openstax_uid ], unique: true
    add_index :openstax_accounts_accounts, :openstax_uid
  end
end
