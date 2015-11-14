class DropTransactionSets < ActiveRecord::Migration
  def change
  	drop_table :transaction_sets
  end
end
