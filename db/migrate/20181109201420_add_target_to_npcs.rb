class AddTargetToNpcs < ActiveRecord::Migration[5.2]
  def change
    add_column :npcs, :target, :integer
  end
end
