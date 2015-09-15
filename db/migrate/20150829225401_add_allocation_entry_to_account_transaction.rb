class AddAllocationEntryToAccountTransaction < ActiveRecord::Migration
  def change
    add_column :account_transactions, :allocation_entry, :float
  end
end
