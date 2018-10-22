class CreateJumpgates < ActiveRecord::Migration[5.2]
  def change
    create_table :jumpgates do |t|
      t.integer :origin_id
      t.integer :destination_id
      t.integer :traveltime

      t.timestamps
    end
  end
end
