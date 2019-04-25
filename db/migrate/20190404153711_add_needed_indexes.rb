class AddNeededIndexes < ActiveRecord::Migration[5.2]
  def change
    # Add an index for anything you use in a where() or order() clause frequently
    add_index :chat_rooms, :identifier, unique: true
    add_index :chat_rooms, :chatroom_type

    add_index :locations, :location_type
    add_index :locations, :station_type
    add_index :locations, :name

    add_index :npcs, :target
    add_index :npcs, :npc_type

    add_index :asteroids, :asteroid_type

    add_index :market_listings, :listing_type
    add_index :market_listings, :order_type

    add_index :systems, :name, unique: true

    add_index :structures, :structure_type

    add_index :missions, :mission_type

    add_index :items, :loader

    add_index :blueprints, :loader
  end
end
