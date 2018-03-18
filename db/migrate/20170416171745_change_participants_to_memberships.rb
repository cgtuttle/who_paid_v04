class ChangeParticipantsToMemberships < ActiveRecord::Migration
  def change
  	rename_table :participants, :memberships
  end
end
