class MiningWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, asteroid_id)
    player = User.find(player_id)
    asteroid = Asteroid.find(asteroid_id)
    
    # Cancel if Player already mining this
    return if player.mining_target_id == asteroid.id
    
    # Untarget combat target if player is targeting mining target
    unless player.target_id == nil
      ActionCable.server.broadcast("player_#{player.target_id}", method: 'getting_targeted', name: player.full_name)
      player.update_columns(target_id: nil)
    end
    
    # Untarget npc target
    player.update_columns(npc_target_id: nil)
    
    # Mine every 30 seconds
    player.update_columns(mining_target_id: asteroid.id)
    while true do
      30.times do
        return unless can_mine(player, asteroid)
        sleep(1)
      end
      asteroid.update_columns(resources: asteroid.resources - 100)
      ActionCable.server.broadcast("player_#{player.id}", method: 'update_asteroid_resources', resources: asteroid.resources)
      item = Item.create(spaceship_id: player.active_spaceship.id, loader: "asteroid.#{asteroid.asteroid_type}")
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_player_info')
      
      # Log
      ActionCable.server.broadcast("player_#{player.id}", method: 'log', text: I18n.t('log.you_mined_from_asteroid', ore: item.get_attribute('name').downcase) )
      
      # Tell other users who miner this rock to also update their resources
      User.where(mining_target_id: asteroid.id).where("online > 0").each do |u|
        ActionCable.server.broadcast("player_#{u.id}", method: 'update_asteroid_resources_only', resources: asteroid.resources)
      end
      
      # Get enemy
      EnemyWorker.perform_async(player.location.id, 5) #if 1 + rand(10) == 10
    end
    
  end
  
  def can_mine(player, asteroid)
    player = player.reload
    asteroid = asteroid.reload
    
    # Remove asteroid as target if depleted
    if asteroid.resources < 100
      ActionCable.server.broadcast("player_#{player.id}", method: 'asteroid_depleted')
      player.update_columns(mining_target_id: nil)
      return false
    end
    
    # Stop mining if user has other or no mining target
    if player.mining_target_id != asteroid.id || player.target_id != nil
      return false
    end
    
    # Stop mining if player's ship is full
    if player.active_spaceship.get_weight >= player.active_spaceship.get_attribute('storage')
      ActionCable.server.broadcast("player_#{player.id}", method: 'asteroid_depleted')
      player.update_columns(mining_target_id: nil)
      return false
    end
    
    player.can_be_attacked and asteroid.resources >= 100
  end
end