class RemoveTransactionSetFromAccountTransaction < ActiveRecord::Migration
  def change
  	remove_column :account_transactions, :transaction_set
  end
end
