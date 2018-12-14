System.all.each do |system|
  # Clear all hidden locations
  system.locations.where(hidden: true).each do |loc|
    loc.destroy if loc.users.empty? and Spaceship.where(warp_target_id: loc.id).empty?
  end
  
  # Add new hidden locations (50%)
  if rand(2) == 1
    rand(2..4).times do
      location = Location.create(system: system, location_type: 'exploration_site', hidden: true, name: 'Exploration Site')
      
      case rand(1..3)
        when 1
          # Enemies with loot
          location.update_columns(enemy_amount: rand(2..4))
        when 2
          # Create Structure with loot
          loader = ITEMS + ASTEROIDS + MATERIALS
          structure = Structure.create(location: location, structure_type: 'wreck')
          rand(2..5).times do
            Item.create(loader: loader.sample, structure: structure, equipped: false)
          end
        when 3
          # Abandoned Spaceship Puzzle
          # TODO
      end
      
    end
  end
  
end