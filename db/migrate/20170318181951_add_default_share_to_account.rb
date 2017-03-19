class AddDefaultShareToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :default_share, :float, default: 1.0
    add_column :accounts, :default_method, :string, default: 'qty'
  end
end
