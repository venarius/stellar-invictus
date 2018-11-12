class AttackNpcWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = Npc.find(target_id)
    
    # Get current active spaceships of player
    player_ship = player.active_spaceship
    
    # While player can attack
    while can_attack(player, target) do
      
      # The attack
      attack = SHIP_VARIABLES[player_ship.name]['power']
      target.update_columns(hp: target.hp - attack.round)
      
      # If target hp is below 0 -> die
      if target.hp <= 0
        target.update_columns(hp: 0)
        target.die and return
      end
      
      # Tell player to update their hp
      ActionCable.server.broadcast("player_#{player.id}", method: 'update_target_health', hp: target.hp)
      
      # Tell other users who targeted npc to also update hp
      User.where(npc_target_id: target.id).where("online > 0").each do |u|
        ActionCable.server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target.hp)
      end
      
      # Global Cooldown
      sleep(2)
    end
  end
  
  def can_attack(player, target)
    player = player.reload
    target = target.reload
    
    # Return true if both can be attacked, are in the same location and player has target locked on
    player.can_be_attacked and target.location == player.location and player.npc_target == target
  end
end