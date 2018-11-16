class CreateStructures < ActiveRecord::Migration[5.2]
  def change
    create_table :structures do |t|
      t.integer :structure_type
      t.references :location, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
