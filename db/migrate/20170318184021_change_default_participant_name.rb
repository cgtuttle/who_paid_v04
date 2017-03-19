class ChangeDefaultParticipantName < ActiveRecord::Migration
  def change
  	rename_column :accounts, :default_participant, :default_participant?
  end
end
