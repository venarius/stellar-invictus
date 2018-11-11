class AddNameToNpcs < ActiveRecord::Migration[5.2]
  def change
    add_column :npcs, :name, :string
  end
end
