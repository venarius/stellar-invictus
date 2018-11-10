class CreateNpcs < ActiveRecord::Migration[5.2]
  def change
    create_table :npcs do |t|
      t.integer :npc_type
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end
