class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.references :account, null: false

      t.timestamps null: false
    end

    add_index :users, :account_id, unique: true
  end
end
