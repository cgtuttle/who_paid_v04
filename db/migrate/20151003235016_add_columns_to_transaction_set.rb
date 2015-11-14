class AddColumnsToTransactionSet < ActiveRecord::Migration
  def change
    add_column :transaction_sets, :type, :string
    add_column :transaction_sets, :reversal, :boolean, null: false, default: false
  end
end
