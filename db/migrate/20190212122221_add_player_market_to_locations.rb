class AddPlayerMarketToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :player_market, :boolean, default: false
  end
end
