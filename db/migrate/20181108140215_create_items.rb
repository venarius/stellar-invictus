class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.references :user, foreign_key: true
      t.references :location, foreign_key: true
      t.references :spaceship, foreign_key: true
      t.string :loader

      t.timestamps
    end
  end
end
