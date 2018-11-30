class MiningWorker
  # This Worker will be run when a player is mining something
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, asteroid_id)
    player = User.find(player_id)
    asteroid = Asteroid.find(asteroid_id)
    
    # Untarget npc target and is_attacking to false
    player.update_columns(npc_target_id: nil, is_attacking: false)
    
    # Cancel if Player already mining this
    return if player.mining_target_id == asteroid_id
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    # Untarget combat target if player is targeting mining target
    unless player.target_id == nil
      ac_server.broadcast("player_#{player.target_id}", method: 'getting_targeted', name: player.full_name)
      player.update_columns(target_id: nil)
    end
    
    # Get mining amount
    mining_amount = player.active_spaceship.get_mining_amount
    
    # Mine every 30 seconds
    player.update_columns(mining_target_id: asteroid_id)
    ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
    while true do
      10.times do
        return unless can_mine(player, asteroid, mining_amount)
        sleep(2)
      end
      
      # Remove amount from asteroids ressources
      asteroid.update_columns(resources: asteroid.resources - (100 * mining_amount))
      
      # Add Items to player
      item = Item.create(spaceship_id: player.active_spaceship.id, loader: "asteroid.#{asteroid.asteroid_type}")
      (mining_amount-1).times do
        Item.create(spaceship_id: player.active_spaceship.id, loader: "asteroid.#{asteroid.asteroid_type}")
      end
      
      # 3 septarium per mine
      if asteroid.asteroid_type == "septarium"
        (mining_amount * 3 - mining_amount).times do
          Item.create(spaceship_id: player.active_spaceship.id, loader: "asteroid.#{asteroid.asteroid_type}")
        end
      end
      
      # Log
      ac_server.broadcast("player_#{player_id}", method: 'update_asteroid_resources', resources: asteroid.resources)
      ac_server.broadcast("player_#{player_id}", method: 'refresh_player_info')
      ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_mined_from_asteroid', ore: item.get_attribute('name').downcase) )
      
      # Tell other users who miner this rock to also update their resources
      User.where(mining_target_id: asteroid_id).where("online > 0").each do |u|
        ac_server.broadcast("player_#{u.id}", method: 'update_asteroid_resources_only', resources: asteroid.resources)
      end
      
      # Get enemy
      EnemyWorker.perform_async(player.location.id, 5) if 1 + rand(10) == 10
    end
    
  end
  
  def can_mine(player, asteroid, mining_amount)
    player = player.reload
    asteroid = asteroid.reload
    
    # Set Variables
    player_id = player.id
    asteroid_id = asteroid.id
    
    # Remove asteroid as target if depleted
    if asteroid.resources < (100 * mining_amount)
      ActionCable.server.broadcast("player_#{player_id}", method: 'asteroid_depleted')
      player.update_columns(mining_target_id: nil)
      return false
    end
    
    # Stop mining if user has other or no mining target
    if player.mining_target_id != asteroid_id || player.target_id != nil
      return false
    end
    
    # Stop mining if player's ship is full
    if player.active_spaceship.get_free_weight < mining_amount and asteroid.asteroid_type != 'septarium'
      ActionCable.server.broadcast("player_#{player_id}", method: 'asteroid_depleted')
      player.update_columns(mining_target_id: nil)
      return false
    end
    
    player.can_be_attacked
  end
end