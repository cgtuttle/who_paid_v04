class ChangeColumnNamesInAccountTransactionsTwo < ActiveRecord::Migration
  def change
    rename_column :accounts, :name, :account_name
  end
end
