class RemoveDefaultParticipantFromAccount < ActiveRecord::Migration
  def change
  	remove_column :accounts, :default_participant?, :boolean
  end
end
