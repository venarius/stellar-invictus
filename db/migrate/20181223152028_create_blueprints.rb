class CreateBlueprints < ActiveRecord::Migration[5.2]
  def change
    create_table :blueprints do |t|
      t.string :loader
      t.float :efficiency, default: 1.5
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
