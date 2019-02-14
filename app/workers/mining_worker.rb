class MiningWorker
  # This Worker will be run when a player is mining something
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, asteroid_id, is_mining=false, check_count=0)
    player = User.find(player_id) rescue nil
    asteroid = Asteroid.find(asteroid_id) rescue nil
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    return unless player.active_spaceship and player and asteroid
    
    # Get mining amount
    mining_amount = player.active_spaceship.get_mining_amount
    
    if !is_mining
    
      # Untarget npc target and is_attacking to false
      player.update_columns(npc_target_id: nil, is_attacking: false)
      
      # Cancel if Player already mining this
      return if player.mining_target_id == asteroid_id
      
      # Untarget combat target if player is targeting mining target
      unless player.target_id == nil
        ac_server.broadcast("player_#{player.target_id}", method: 'stopping_target', name: player.full_name)
        player.update_columns(target_id: nil)
      end
      
      # Mine every 30 seconds
      player.update_columns(mining_target_id: asteroid_id)
      ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
      
      MiningWorker.perform_in(2.second, player.id, asteroid.id, true, check_count + 2) and return
      
    elsif check_count < 20
    
      return unless can_mine(player, asteroid, mining_amount)
      MiningWorker.perform_in(2.second, player.id, asteroid.id, true, check_count + 2) and return
    
    else
      
      # Remove amount from asteroids ressources
      mining_amount = asteroid.resources / 100 unless asteroid.resources >= 100 * mining_amount
      asteroid.update_columns(resources: asteroid.resources - (100 * mining_amount))
      
      
      # Add Items to player
      if player.active_spaceship.get_free_weight < (mining_amount - 1)
        Item.give_to_user({loader: "asteroid.#{asteroid.asteroid_type}_ore", count: player.active_spaceship.get_free_weight, user: player})
      else
        Item.give_to_user({loader: "asteroid.#{asteroid.asteroid_type}_ore", count: mining_amount-1, user: player})
      end
      
      # Log
      ac_server.broadcast("player_#{player_id}", method: 'update_asteroid_resources', resources: asteroid.resources)
      ac_server.broadcast("player_#{player_id}", method: 'refresh_player_info')
      
      # Tell other users who miner this rock to also update their resources
      User.where(mining_target_id: asteroid_id).where("online > 0").each do |u|
        ac_server.broadcast("player_#{u.id}", method: 'update_asteroid_resources_only', resources: asteroid.resources)
      end
      
      # Add to mission if user has active mission
      mission = player.missions.where(mission_loader: "asteroid.#{asteroid.asteroid_type}_ore", mission_status: 'active', mission_type: 'mining').where("mission_amount > 0").first rescue nil
      if mission
        mission.update_columns(mission_amount: mission.mission_amount - mining_amount)
        mission.update_columns(mission_amount: 0) if mission.mission_amount < 0
      end
      
      # Log
      ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_mined_from_asteroid', amount: mining_amount, ore: item.get_attribute('name').downcase) )
      
      # Get enemy
      EnemyWorker.perform_async(nil, player.location.id) if rand(10) == 9
      
      # Restart MiningWorker
      MiningWorker.perform_async(player.id, asteroid_id, true) and return
      
    end
  end
  
  def can_mine(player, asteroid, mining_amount)
    player = player.reload
    asteroid = asteroid.reload rescue nil
    
    # Set Variables
    player_id = player.id
    asteroid_id = asteroid.id rescue nil
    
    # Remove asteroid as target if depleted
    if asteroid.resources <= 0
      # Tell other users who miner this rock is depleted
      User.where(mining_target_id: asteroid_id).where("online > 0").each do |u|
        ActionCable.server.broadcast("player_#{u.id}", method: 'asteroid_depleted')
      end
      
      asteroid.destroy
      ActionCable.server.broadcast("player_#{player_id}", method: 'asteroid_depleted')
      
      player.update_columns(mining_target_id: nil)
      return false
    end
    
    # Stop mining if user has other or no mining target
    if player.mining_target_id != asteroid_id || player.target_id != nil
      return false
    end
    
    # Stop mining if player's ship is full
    if player.active_spaceship.get_free_weight <= 0
      ActionCable.server.broadcast("player_#{player_id}", method: 'asteroid_depleted')
      player.update_columns(mining_target_id: nil)
      return false
    end
    
    player.can_be_attacked
  end
end