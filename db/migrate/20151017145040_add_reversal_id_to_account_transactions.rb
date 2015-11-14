class AddReversalIdToAccountTransactions < ActiveRecord::Migration
  def change
    add_column :account_transactions, :reversal_id, :integer
  end
end
