class CreateOpenStaxAccountsGroupMembers < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_group_members do |t|
      t.reference :group
      t.reference :user

      t.timestamps
    end
  end
end
