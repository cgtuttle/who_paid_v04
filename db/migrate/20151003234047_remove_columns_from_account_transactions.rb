class RemoveColumnsFromAccountTransactions < ActiveRecord::Migration
  def change
  	change_table :account_transactions do |t|
  		t.remove :occured_on
  		t.remove :journal_id
  		t.remove :journal_type
  	end
  end
end
