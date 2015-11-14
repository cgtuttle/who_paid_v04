class RemoveAllocationsFromAccountTransactions < ActiveRecord::Migration
  def change
  	change_table :account_transactions do |t|
  		t.remove :allocation_factor
  		t.remove :allocation_method
  		t.remove :allocation_entry
  	end
  end
end
