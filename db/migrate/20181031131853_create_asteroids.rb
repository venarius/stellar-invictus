class CreateAsteroids < ActiveRecord::Migration[5.2]
  def change
    create_table :asteroids do |t|
      t.references :location, foreign_key: true
      t.integer :asteroid_type
      t.integer :ressources

      t.timestamps
    end
  end
end
