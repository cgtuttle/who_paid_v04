class DropPayees < ActiveRecord::Migration
  def up
  	drop_table :payees
  end
end
