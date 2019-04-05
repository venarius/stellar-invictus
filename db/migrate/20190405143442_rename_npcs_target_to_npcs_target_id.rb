class RenameNpcsTargetToNpcsTargetId < ActiveRecord::Migration[5.2]
  def change
    rename_column :npcs, :target, :target_id
  end
end
