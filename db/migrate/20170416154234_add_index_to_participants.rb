class AddIndexToParticipants < ActiveRecord::Migration
  def change
  	
  	add_index :participants, [:user_id, :event_id], :unique => true
  	
  end
end
