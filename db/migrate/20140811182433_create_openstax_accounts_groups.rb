class CreateOpenStaxAccountsGroups < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_groups do |t|
      t.string :name
      t.boolean :is_public
      t.text :cached_subtree_group_ids
      t.text :cached_supertree_group_ids

      t.timestamps
    end
  end
end
