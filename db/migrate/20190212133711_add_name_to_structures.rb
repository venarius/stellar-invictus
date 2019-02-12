class AddNameToStructures < ActiveRecord::Migration[5.2]
  def change
    add_column :structures, :name, :string
    add_column :structures, :description, :text
  end
end
