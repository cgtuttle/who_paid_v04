class SetInactiveNullToFalse < ActiveRecord::Migration
  def change
  	change_column_null :accounts, :inactive, false
  end
end
