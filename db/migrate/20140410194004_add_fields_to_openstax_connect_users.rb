class AddFieldsToOpenStaxConnectUsers < ActiveRecord::Migration
  def change
    add_column :openstax_connect_users, :full_name, :string
    add_column :openstax_connect_users, :title, :string
    add_column :openstax_connect_users, :access_token, :string
  end
end
