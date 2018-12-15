System.all.each do |system|
  # Clear all hidden locations
  system.locations.where(hidden: true).each do |loc|
    loc.destroy if loc.users.empty? and Spaceship.where(warp_target_id: loc.id).empty?
  end
  
  # Add new hidden locations (50%)
  if rand(2) == 1
    rand(2..4).times do
      location = Location.create(system: system, location_type: 'exploration_site', hidden: true, name: 'Exploration Site')
      
      case rand(1..4)
        when 1
          # Enemies with loot
          amount = rand(2..5)
          amount = amount * 2 if location.system.security_status == 'low'
          location.update_columns(enemy_amount: amount)
        when 2
          # Create Structure with loot and some enemies
          loader = ITEMS + ASTEROIDS + MATERIALS
          structure = Structure.create(location: location, structure_type: 'wreck')
          amount = rand(2..5)
          amount = amount * 3 if location.system.security_status == 'low'
          amount.times do
            Item.create(loader: loader.sample, structure: structure, equipped: false)
          end
          location.update_columns(enemy_amount: rand(1..2))
        when 3
          # Abandoned Ship with Riddle
          loader = ITEMS + ASTEROIDS + MATERIALS
          structure = Structure.create(location: location, structure_type: 'abandoned_ship', riddle: rand(1..23))
          amount = rand(4..5)
          amount = amount * 3 if location.system.security_status == 'low'
          amount.times do
            Item.create(loader: loader.sample, structure: structure, equipped: false)
          end
        when 4
          # Asteroids
          rand(3..5).times do 
            Asteroid.create(location: location, asteroid_type: 4, resources: 35000)
          end
      end
      
    end
  end
  
end