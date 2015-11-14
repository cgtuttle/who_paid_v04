class RemoveIdColumnsFromAccountTransactions < ActiveRecord::Migration
  def change
    remove_column :account_transactions, :transaction_set_id, :integer
    remove_column :account_transactions, :allocation_id, :string
  end
end
