class AddJournalsToAccountTransactions < ActiveRecord::Migration
  def change
    add_column :account_transactions, :journal_id, :integer
    add_column :account_transactions, :journal_type, :string
    remove_column :account_transactions, :for
    rename_column :account_transactions, :allocation, :allocation_factor
    rename_column :account_transactions, :allocation_type, :allocation_method
  end
end
