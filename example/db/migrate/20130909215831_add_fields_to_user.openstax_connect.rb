# This migration comes from openstax_connect (originally 20130909215452)
class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :is_administrator, :boolean, :default => false

    add_index :users, :openstax_uid, :unique => true
    add_index :users, :username, :unique => true
  end

end
