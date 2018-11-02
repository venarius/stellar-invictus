class CreateSpaceships < ActiveRecord::Migration[5.2]
  def change
    create_table :spaceships do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :image
      t.integer :hp
      t.integer :armor
      t.integer :power
      t.integer :defense
      t.integer :price

      t.timestamps
    end
  end
end
