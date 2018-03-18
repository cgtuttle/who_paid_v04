class ChangeAccountName < ActiveRecord::Migration
  def change
  	rename_column :accounts, :name, :name
  end
end
