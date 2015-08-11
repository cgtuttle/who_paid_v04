class ChangeColumnNamesInAccountTransactions < ActiveRecord::Migration
  def change
    change_table :account_transactions do |t|
      t.rename :parent_id, :parent_entry_id
      t.rename :type, :entry_type
    end
  end
end
