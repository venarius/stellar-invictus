System.all.each do |system|
  # Clear all hidden locations
  system.locations.where(hidden: true).each do |loc|
    loc.destroy if loc.users.empty? and Spaceship.where(warp_target_id: loc.id).empty?
  end
  
  # Add new hidden locations (50%)
  if rand(2) == 1
    rand(2..4).times do
      location = Location.create(system: system, location_type: 'exploration_site', hidden: true)
      
      case rand(1..5)
        when 1
          # Enemies with loot
          amount = rand(2..5)
          amount = amount * 2 if location.system_security_status == 'low'
          location.update_columns(enemy_amount: amount, name: I18n.t('exploration.combat_site'))
        when 2
          # Create Structure with loot and some enemies
          loader = ITEMS + ASTEROIDS + MATERIALS
          structure = Structure.create(location: location, structure_type: 'wreck')
          amount = rand(2..5)
          amount = amount * 3 if location.system_security_status == 'low'
          amount.times do
            Item.create(loader: loader.sample, structure: structure, equipped: false)
          end
          location.update_columns(enemy_amount: rand(1..2), name: I18n.t('exploration.combat_site'))
        when 3
          # Abandoned Ship with Riddle
          loader = ITEMS + ASTEROIDS + MATERIALS
          structure = Structure.create(location: location, structure_type: 'abandoned_ship', riddle: rand(1..23))
          amount = rand(4..5)
          amount = amount * 3 if location.system_security_status == 'low'
          amount.times do
            Item.create(loader: loader.sample, structure: structure, equipped: false)
          end
          location.update_columns(name: I18n.t('exploration.emergency_beacon'))
        when 4
          # Asteroids
          rand(3..5).times do 
            Asteroid.create(location: location, asteroid_type: 4, resources: 35000)
          end
          location.update_columns(name: I18n.t('exploration.mining_site'))
        when 5
          # Hard to kill NPC with lots of bounty
          location.update_columns(enemy_amount: 1)
          location.update_columns(name: I18n.t('exploration.outlaw_hideout'))
      end
      
    end
  end
  
end