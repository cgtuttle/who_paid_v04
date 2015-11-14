class AddTransactionSetIdToAccountTransaction < ActiveRecord::Migration
  def change
    add_column :account_transactions, :transaction_set_id, :integer, index: true
  end
end
