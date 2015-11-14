class CreateAllocations < ActiveRecord::Migration
  def change
    create_table :allocations do |t|
      t.references :event, index: true, foreign_key: true
      t.references :journal, polymorphic: true
      t.references :account, index: true, foreign_key: true
      t.string :allocation_method
      t.decimal :allocation_entry
      t.string :allocation_factor_decimal

      t.timestamps null: false
    end
  end
end
