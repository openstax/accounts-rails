class ChangeAccountsUsernameToBeNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null :openstax_accounts_accounts, :username, true
  end
end
