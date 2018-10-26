class AddLocationToFactions < ActiveRecord::Migration[5.2]
  def change
    add_reference :factions, :location, foreign_key: true
  end
end
