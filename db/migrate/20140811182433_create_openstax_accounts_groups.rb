class CreateOpenStaxAccountsGroups < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_groups do |t|
      t.string :name
      t.boolean :is_public, null: false
      t.text :cached_subtree_group_ids
      t.text :cached_supertree_group_ids

      t.timestamps
    end

    add_index :openstax_accounts_groups, :is_public
  end
end
