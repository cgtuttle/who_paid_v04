class ChangeAllocationFactorToDecimal < ActiveRecord::Migration
  def change
  	change_table :allocations do |t|
  		t.remove :allocation_factor_decimal
  		t.decimal :allocation_factor
  	end
  end
end
