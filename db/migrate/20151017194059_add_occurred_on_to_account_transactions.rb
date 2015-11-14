class AddOccurredOnToAccountTransactions < ActiveRecord::Migration
  def change
    add_column :account_transactions, :occurred_on, :date
  end
end
