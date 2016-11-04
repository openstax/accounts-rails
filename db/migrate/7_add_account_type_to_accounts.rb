class AddAccountTypeToAccounts < ActiveRecord::Migration
  def change
    add_column :openstax_accounts_accounts, :account_type, :integer

    OpenStax::Accounts::Account.find_each do |account|
      account.set_account_type
      account.save!
    end

    change_column_null :openstax_accounts_accounts, :account_type, false
    add_index :openstax_accounts_accounts, :account_type

    change_column_null :openstax_accounts_accounts, :openstax_uid, true
  end
end
