class CreateParticipants < ActiveRecord::Migration
  def change
    create_join_table :users, :events, table_name: :participants
  end
end
