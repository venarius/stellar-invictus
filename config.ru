# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

run Rails.application

# ##############################
#            CUSTOM
# ##############################

require "#{Rails.root.to_s}/config/initializers/variables.rb"

# User
User.all.each do |user|
   user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
   user.update_columns(docked: false) if user.docked.nil?
end

# Asteroids
Location.where(location_type: 'asteroid_field').each do |loc|
  if loc.asteroids.count < 5
    rand(5..10).times do 
      Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
    end
    rand(3..5).times do 
      Asteroid.create(location: loc, asteroid_type: 3, resources: 35000)
    end
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
def get_item_attribute(loader, attribute)
  atty = loader.split(".")
  out = ITEM_VARIABLES[atty[0]]
  loader.count('.').times do |i|
    out = out[atty[i+1]]
  end
  out[attribute] rescue nil
end
  
MarketListing.destroy_all
noise = Perlin::Noise.new 1, seed: Time.now.to_i
Location.where(location_type: 'station').each_with_index do |location, index|
  rabat = noise[(index + 1.0) / 10.0] + 0.5
  ITEMS.each do |item|
    rand(0..1).times do
      rand(3..15).times do
        MarketListing.create(loader: item, location: location, listing_type: 'item', price: (get_item_attribute(item, 'price') * rabat * rand(0.95..1.05)).round, amount: rand(10..30))
      end
    end
  end
  STATION_VARIABLES[location.id]['spaceships'].each do |ship|
    rand(1..10).times do
      MarketListing.create(loader: ship, location: location, listing_type: 'ship', price: (SHIP_VARIABLES[ship]['price'] * rabat * rand(0.95..1.05)).round, amount: rand(1..3))
    end
  end
end

# Mission Scunk
Location.where(location_type: 'mission', mission: nil).destroy_all