class AddSubJournalToAccountTransactions < ActiveRecord::Migration
  def change
    add_column :account_transactions, :sub_journal_id, :integer
    add_column :account_transactions, :sub_journal_type, :string
  end
end
