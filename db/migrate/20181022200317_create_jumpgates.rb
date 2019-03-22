class CreateJumpgates < ActiveRecord::Migration[5.2]
  def change
    create_table :jumpgates do |t|
      t.integer :origin_id
      t.integer :destination_id
      t.integer :traveltime

      t.index :origin_id
      t.index :destination_id

      t.timestamps
    end
  end
end
