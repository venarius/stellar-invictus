begin

  # User
  if ActiveRecord::Base.connection.table_exists? 'users'
    User.all.each do |user|
       user.update_columns(online: 0, in_warp: false, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
       user.update_columns(docked: false) if user.docked.nil?
    end
  end
  
  # Asteroids
  if ActiveRecord::Base.connection.table_exists? 'asteroids'
    Asteroid.destroy_all
    Location.where(location_type: 'asteroid_field').each do |loc|
      rand(5..10).times do 
        Asteroid.create(location: loc, asteroid_type: rand(3), resources: 35000)
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
    ship.update_columns(warp_scrambled: false, warp_target_id: nil)
  end
  
rescue StandardError
  true
end