class AddUnitsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :units, :integer, default: 10
  end
end
