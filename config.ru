# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

require "#{Rails.root.to_s}/config/initializers/variables.rb"

# User
User.all.each do |user|
   user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
   user.update_columns(docked: false) if user.docked.nil?
end

# Asteroids
Asteroid.destroy_all
Location.where(location_type: 'asteroid_field').each do |loc|
  rand(5..10).times do 
    Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
  end
  rand(3..5).times do 
    Asteroid.create(location: loc, asteroid_type: 3, resources: 35000)
  end
end

# NPC
Npc.destroy_all

# Cargocontainer
Structure.where(structure_type: 'container').destroy_all
# Wrecks
Structure.where(structure_type: 'wreck').destroy_all

# Ships
Spaceship.all.each do |ship|
  ship.update_columns(warp_scrambled: false, warp_target_id: nil, hp: SHIP_VARIABLES[ship.name]['hp'])
end

# Items
Item.all.each do |item|
  item.update_columns(active: false)
end

# Market Listing
MarketListing.destroy_all
Location.where(location_type: 'station').each do |location|
  EQUIPMENT.each do |equipment|
    rand(0..1).times do
      rand(1..10).times do
        MarketListing.create(loader: equipment, location: location, listing_type: 'item', price: (100 * rand(0.8..1.2)).round)
      end
    end
  end
  STATION_VARIABLES[location.id]['spaceships'].each do |ship|
    rand(1..10).times do
      MarketListing.create(loader: ship, location: location, listing_type: 'ship', price: (SHIP_VARIABLES[ship]['price'] * rand(0.8..1.2)).round)
    end
  end
end