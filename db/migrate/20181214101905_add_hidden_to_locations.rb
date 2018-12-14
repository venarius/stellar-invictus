class AddHiddenToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :hidden, :boolean, default: false
    add_column :locations, :enemy_amount, :integer, default: 0
  end
end
