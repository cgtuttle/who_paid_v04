class AddForToAccountTransactions < ActiveRecord::Migration
  def change
    add_column :account_transactions, :for, :string
  end
end
