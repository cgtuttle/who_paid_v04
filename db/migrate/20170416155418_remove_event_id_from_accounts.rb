class RemoveEventIdFromAccounts < ActiveRecord::Migration
  def change
  	remove_column :accounts, :event_id, :integer
  end
end
