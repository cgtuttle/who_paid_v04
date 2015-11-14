class CreateTransactionSets < ActiveRecord::Migration
  def change
    create_table :transaction_sets do |t|
      t.references :journal, polymorphic: true, index: true
      t.date :occured_on

      t.timestamps null: false
    end
  end
end
