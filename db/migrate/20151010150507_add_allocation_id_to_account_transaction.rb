class AddAllocationIdToAccountTransaction < ActiveRecord::Migration
  def change
    add_column :account_transactions, :allocation_id, :integer
  end
end
