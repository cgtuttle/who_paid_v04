class DropParticipants < ActiveRecord::Migration
  def up
  	drop_table :participants
  end
end
