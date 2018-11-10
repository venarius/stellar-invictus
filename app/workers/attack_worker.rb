class AttackWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = User.find(target_id)
    
    # Get current active spaceships of each
    player_ship = player.active_spaceship
    target_ship = target.active_spaceship
    
    # Tell target its getting attacked by player
    ActionCable.server.broadcast("player_#{target.id}", method: 'getting_attacked', name: player.full_name)
    
    # Call Police on systems with sec higher than low
    call_police(player)
    
    # While player and target can attack
    while can_attack(player, target) do
      
      # The attack
      attack = SHIP_VARIABLES[player_ship.name]['power'] * (1.0 - SHIP_VARIABLES[target_ship.name]['defense']/100.0)
      target_ship.update_columns(hp: target_ship.hp - attack.round)
      
      # If target hp is below 0 -> die
      if target_ship.hp <= 0
        target_ship.update_columns(hp: 0)
        target.die and return
      end
      
      # Tell both parties to update their hp
      ActionCable.server.broadcast("player_#{target.id}", method: 'update_health', hp: target_ship.hp)
      ActionCable.server.broadcast("player_#{player.id}", method: 'update_target_health', hp: target_ship.hp)
      
      # Global Cooldown
      sleep(2)
    end
  end
  
  def can_attack(player, target)
    player = player.reload
    target = target.reload
    
    # Return true if both can be attacked, are in the same location and player has target locked on
    target.can_be_attacked and player.can_be_attacked and target.location == player.location and player.target == target 
  end
  
  def call_police(player)
    if player.system.security_status != 'low'
      if player.system.security_status == 'high'
        PoliceWorker.perform_async(player.id, 2)
      else
        PoliceWorker.perform_async(player.id, 10)
      end
    end
  end
end