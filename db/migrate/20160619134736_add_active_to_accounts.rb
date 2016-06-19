class AddActiveToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :inactive, :boolean, default: false
  end
end
