class AttackNpcWorker
  # This worker will be run when a player is attacking an npc
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = Npc.find(target_id)
    
    # Get current active spaceships of player
    player_ship = player.active_spaceship
    
    # Check Septarium
    return if !check_septarium(player)
    
    # While player can attack
    while true do
      
      # Math the attack
      power = player_ship.get_power
      
      # If is attacking else
      if power > 0 and !player.is_attacking
        player.update_columns(is_attacking: true)
      elsif power == 0 and player.is_attacking
        player.update_columns(is_attacking: false)
        ActionCable.server.broadcast("player_#{player_id}", method: 'refresh_target_info')
        shutdown(player) and return
      else
        shutdown(player) and return
      end
      
      # Global Cooldown
      sleep(2)
      
      if can_attack(player, target)
        # The attack
        target.update_columns(hp: target.hp - power.round)
        
        # If target hp is below 0 -> die
        if target.hp <= 0
          target.update_columns(hp: 0)
          target.die and shutdown(player) and return
        end
        
        # Tell player to update their hp and log
        ActionCable.server.broadcast("player_#{player.id}", method: 'update_target_health', hp: target.hp)
        ActionCable.server.broadcast("player_#{player.id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: target.name, hp: power))
        
        # Tell other users who targeted npc to also update hp
        User.where(npc_target_id: target.id).where("online > 0").each do |u|
          ActionCable.server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target.hp)
        end
      else
        shutdown(player) and return
      end
    end
  end
  
  def can_attack(player, target)
    player = player.reload
    target = target.reload
    
    # Return true if both can be attacked, are in the same location and player has target locked on
    player.can_be_attacked and target.location == player.location and player.npc_target == target and player.is_attacking and check_septarium(player)
  end
  
  def shutdown(player)
    player.active_spaceship.deactivate_equipment
    player.update_columns(is_attacking: false)
  end
  
  def check_septarium(player)
    if player.active_spaceship.get_septarium_usage > player.active_spaceship.get_septarium 
      if player.is_attacking
        player.update_columns(is_attacking: false)
      end
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
      ActionCable.server.broadcast("player_#{player.id}", method: 'show_error', text: I18n.t('errors.not_enough_septarium'))
      false
    end
    true
  end
end