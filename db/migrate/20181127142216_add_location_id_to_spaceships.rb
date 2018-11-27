class AddLocationIdToSpaceships < ActiveRecord::Migration[5.2]
  def change
    add_reference :spaceships, :location, foreign_key: true
  end
end
