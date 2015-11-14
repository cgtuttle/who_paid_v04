class AddDeletedToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :deleted, :boolean, null: false, default: false
  end
end
