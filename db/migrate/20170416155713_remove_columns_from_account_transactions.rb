class RemoveColumnsFromAccountTransactions < ActiveRecord::Migration
  def change
  	remove_column :account_transactions, :sub_journal_id, :integer
  	remove_column :account_transactions, :sub_journal_type, :string
  end
end
