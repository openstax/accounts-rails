class CreateOpenStaxAccountsCache < ActiveRecord::Migration
  def change
    create_table :openstax_accounts_cache do |t|
      t.datetime :last_updated_at
    end
  end
end
