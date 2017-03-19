class AddDefaultParticipantToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :default_participant, :boolean, { default: true, null: false}
  end
end
