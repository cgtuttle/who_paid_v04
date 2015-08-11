class CreateParticipants < ActiveRecord::Migration
  def change
    create_join_table :event, :user, table_name: :participants do |t|
      t.index :event_id
      t.index :user_id
      t.timestamps null: false
    end
  end
end
