class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :locations do |t|
      t.string :name
      t.references :system, foreign_key: true
      t.integer :location_type

      t.timestamps
    end
  end
end
