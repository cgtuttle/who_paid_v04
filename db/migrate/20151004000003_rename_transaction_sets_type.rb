class RenameTransactionSetsType < ActiveRecord::Migration
  def change
  	rename_column :transaction_sets, :type, :set_type
  end
end
