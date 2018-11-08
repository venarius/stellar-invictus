class AsteroidsRenameRessourcesToResources < ActiveRecord::Migration[5.2]
  def change
    rename_column :asteroids, :ressources, :resources
  end
end
