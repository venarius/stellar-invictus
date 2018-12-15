class AddRiddleToStructure < ActiveRecord::Migration[5.2]
  def change
    add_column :structures, :riddle, :integer
  end
end
