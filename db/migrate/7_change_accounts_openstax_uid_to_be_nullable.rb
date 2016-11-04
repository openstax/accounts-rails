class ChangeAccountsOpenStaxUidToBeNullable < ActiveRecord::Migration
  def change
    change_column_null :openstax_accounts_accounts, :openstax_uid, true
  end
end
