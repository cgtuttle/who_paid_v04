class AddJournalToAccountTransactions < ActiveRecord::Migration
  def change
    add_column :account_transactions, :journal_id, :integer
    add_column :account_transactions, :journal_type, :string
  end
end
