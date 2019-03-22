System.all.each do |system|

  # Wormholes have their own locations
  next if system.wormhole?

  # Clear all hidden locations
  system.locations.where(hidden: true).each do |loc|
    loc.destroy if loc.users.empty? && Spaceship.where(warp_target_id: loc.id).empty? && !loc.wormhole?
  end

  # Add new hidden locations (50%)
  if rand(2) == 1
    rand(2..4).times do
      location = Location.create(system: system, location_type: 'exploration_site', hidden: true)

      case rand(1..6)
      when 1
        # Enemies with loot
        amount = rand(2..5)
          amount = amount * 2 if location.system_security_status == 'low'
          location.update_columns(enemy_amount: amount, name: I18n.t('exploration.combat_site'))
      when 2
        # Create Structure with loot and some enemies
        loader = Item.asteroids + Item.materials
          structure = Structure.create(location: location, structure_type: 'wreck')
          amount = rand(2..3)
          amount = amount * 3 if location.system_security_status == 'low'
          case rand(1..100)
          when 1..75
            Item.create(loader: (loader + Item.equipment_easy).sample, structure: structure, equipped: false, count: amount)
          when 76..95
            Item.create(loader: (loader + Item.equipment_medium).sample, structure: structure, equipped: false, count: amount)
          when 96..100
            Item.create(loader: (loader + Item.equipment_hard).sample, structure: structure, equipped: false, count: amount)
          end
          location.update_columns(enemy_amount: rand(1..2), name: I18n.t('exploration.combat_site'))
      when 3
        # Abandoned Ship with Riddle
        loader = Item.asteroids + Item.materials
          structure = Structure.create(location: location, structure_type: 'abandoned_ship', riddle: rand(1..30))
          amount = rand(3..4)
          amount = amount * 3 if location.system_security_status == 'low'
          case rand(1..100)
          when 1..75
            Item.create(loader: (loader + Item.equipment_easy).sample, structure: structure, equipped: false, count: amount)
          when 76..95
            Item.create(loader: (loader + Item.equipment_medium).sample, structure: structure, equipped: false, count: amount)
          when 96..100
            Item.create(loader: (loader + Item.equipment_hard).sample, structure: structure, equipped: false, count: amount)
          end
          location.update_columns(name: I18n.t('exploration.lost_wreck'))
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
      when 6
        # Wreck with Passengers
        location.update_columns(enemy_amount: rand(4..6))
          location.update_columns(name: I18n.t('exploration.emergency_beacon'))
      end

    end
  end

end
