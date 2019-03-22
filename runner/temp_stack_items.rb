# Update all users to move to first system
User.update_all(location_id: Location.where(location_type: :station).first.id, system_id: Location.where(location_type: :station).first.system.id, docked: true)

# Delete all Hidden Locations
Location.where(hidden: true).each do |loc|
  loc.destroy if loc.users.empty? && Spaceship.where(warp_target_id: loc.id).empty?
end

# Delete all Missions
Mission.where(mission_status: :offered).each do |mission|
  if mission.mission_location
    next unless mission.mission_location.users.empty? && Spaceship.where(warp_target_id: mission.mission_location.id).empty?
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
raise "error" if Item.where.not(location: Location.where(location_type: :station).first).present?

# Stacking
User.all.each do |user|
  loaders = Item.where(location: Location.where(location_type: :station).first.id, user: user).map(&:loader).uniq

    next unless loaders

    loaders.each do |loader|
      items = Item.where(location: Location.where(location_type: :station).first.id, loader: loader, user: user)
        if items.present?
          counter = 0
            items.each do |i|
              counter = counter + i.count
            end
            items.delete_all
            Item.create(location: Location.where(location_type: :station).first, loader: loader, user: user, count: counter)
            puts Item.count
        end
    end
end
