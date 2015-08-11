class CreateAccountTransactions < ActiveRecord::Migration
  def change
    create_table :account_transactions do |t|
      t.references :account, index: true, foreign_key: true
      t.references :parent, index: true
      t.date :occured_on
      t.decimal :debit
      t.decimal :credit
      t.string :type
      t.decimal :allocation
      t.string :allocation_type

      t.timestamps null: false
    end
  end
end
