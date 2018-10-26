class AddFactionToLocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :locations, :faction, foreign_key: true
  end
end
