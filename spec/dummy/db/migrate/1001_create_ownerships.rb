class CreateOwnerships < ActiveRecord::Migration[4.2]
  def change
    create_table :ownerships do |t|
      t.references :owner, polymorphic: true, null: false

      t.timestamps null: false
    end

    add_index :ownerships, [:owner_id, :owner_type], unique: true
  end
end
