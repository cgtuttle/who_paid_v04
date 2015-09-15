class RenameParentEntryIdInAccountTransaction < ActiveRecord::Migration
  def change
    rename_column :account_transactions, :parent_entry_id, :transaction_set
  end
end
