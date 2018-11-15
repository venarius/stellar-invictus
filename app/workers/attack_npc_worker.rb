class AttackNpcWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = Npc.find(target_id)
    
    # Get current active spaceships of player
    player_ship = player.active_spaceship
    
    # If already target -> untarget
    if player.is_attacking
      player.update_columns(is_attacking: false)
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
      return
    end
    
    # Set is attacking to true
    player.update_columns(is_attacking: true)
    
    # While player can attack
    while true do
      # Global Cooldown
      sleep(2)
      
      if can_attack(player, target)
        # The attack
        attack = SHIP_VARIABLES[player_ship.name]['power']
        target.update_columns(hp: target.hp - attack.round)
        
        # If target hp is below 0 -> die
        if target.hp <= 0
          target.update_columns(hp: 0)
          target.die and return
        end
        
        # Tell player to update their hp and log
        ActionCable.server.broadcast("player_#{player.id}", method: 'update_target_health', hp: target.hp)
        ActionCable.server.broadcast("player_#{player.id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: target.name, hp: attack))
        
        # Tell other users who targeted npc to also update hp
        User.where(npc_target_id: target.id).where("online > 0").each do |u|
          ActionCable.server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target.hp)
        end
      end
    end
  end
  
  def can_attack(player, target)
    player = player.reload
    target = target.reload
    
    # Return true if both can be attacked, are in the same location and player has target locked on
    player.can_be_attacked and target.location == player.location and player.npc_target == target and player.is_attacking
  end
end