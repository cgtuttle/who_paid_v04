class ChangeAccountTransactionColumns < ActiveRecord::Migration
  def change
  	change_table :account_transactions do |t|
  		t.integer :source_id
  		t.string :source_type
  	end
  end
end
