class AddStructureIdToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :structure_id, :integer
  end
end
