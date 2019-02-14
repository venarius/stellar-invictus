# Update all users to move to first system
User.update_all(location_id: Location.where(location_type: :station).first.id, system_id: Location.where(location_type: :station).first.system.id, docked: true)

# Delete all Hidden Locations
Location.where(hidden: true).each do |loc|
    loc.destroy if loc.users.empty? and Spaceship.where(warp_target_id: loc.id).empty?
end

# Delete all Missions
Mission.where(mission_status: :offered).each do |mission|
  if mission.mission_location
    next unless mission.mission_location.users.empty? and Spaceship.where(warp_target_id: mission.mission_location.id).empty?
  end
  
  mission.destroy
end

# Cargocontainer
Structure.where(structure_type: 'container').destroy_all
# Wrecks
Structure.where(structure_type: 'wreck').destroy_all

# Mission Scunk
Location.where(location_type: 'mission', mission: nil).destroy_all

# Move all items to first station
Spaceship.all.each do |ship|
    ship.items.each do |item|
        item.update_columns(user_id: ship.user.id, location_id: ship.user.location.id, spaceship_id: nil, equipped: false, active: false)
    end
end
Spaceship.update_all(location_id: Location.where(location_type: :station).first.id)

# Move all items from stations to first station
Location.where(location_type: :station).each do |loc|
    loc.items.update_all(location_id: Location.where(location_type: :station).first.id, equipped: false, active: false)
end

# Check for Items
raise "blub" if Item.where.not(location: Location.where(location_type: :station).first).present?

# Stacking
Item.all.each do |item|
    items =  Item.where(location: item.location, loader: item.loader, user: item.user).where.not(id: item.id)
    if items.present?
        counter = 0
        items.each do |i|
           counter = counter + i.count
           i.delete
        end
        item.update_columns(count: item.count + counter)
        puts Item.count
    end
end