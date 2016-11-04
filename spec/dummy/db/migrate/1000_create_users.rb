class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :account, null: false

      t.timestamps
    end

    add_index :users, :account_id, unique: true
  end
end
