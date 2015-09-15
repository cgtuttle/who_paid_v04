class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :event, index: true, foreign_key: true
      t.date :payment_date
      t.integer :account_from
      t.integer :account_to
      t.decimal :amount
      t.string :for

      t.timestamps null: false
    end
  end
end
