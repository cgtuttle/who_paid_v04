class RemoveEventIdFromAllocation < ActiveRecord::Migration
  def change
    remove_column :allocations, :event_id, :integer
  end
end
