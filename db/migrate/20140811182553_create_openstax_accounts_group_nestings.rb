class CreateOpenStaxAccountsGroupNestings < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_group_nestings do |t|
      t.reference :member_group
      t.reference :container_group

      t.timestamps
    end
  end
end
