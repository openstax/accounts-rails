class ChangeAccountsOpenStaxUidToBeNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null :openstax_accounts_accounts, :openstax_uid, true
  end
end
