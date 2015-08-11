class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.references :source, polymorphic: true, index: true
      t.string :name
      t.references :event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
