class AddStationTypeToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :station_type, :integer
  end
end
