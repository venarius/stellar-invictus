class AttackWorker
  # This Worker will be run when a player is attacking another
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = User.find(target_id)
    player_name = player.full_name
    
    # Sets ActionCable Server
    ac_server = ActionCable.server
    
    # Get current active spaceships of each
    player_ship = player.active_spaceship
    target_ship = target.active_spaceship
    
    # Check Septarium
    return if !check_septarium(player, target)
    
    # While player and target can attack
    while true do
      
      # Get power
      power = player_ship.get_power
        
      # If is attacking else
      if power > 0 and !player.is_attacking
        call_police(player, target)
        player.update_columns(is_attacking: true)
        ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: player_name)
      elsif power == 0 and player.is_attacking
        player.update_columns(is_attacking: false)
        ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: player_name)
        ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
        shutdown(player) and return
      else
        ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
        shutdown(player) and return
      end
      
      
      # Global Cooldown
      sleep(2)
      
      if can_attack(player, target)
        
        # Remove septarium
        player.active_spaceship.use_septarium
        
        # The attack
        attack = power * (1.0 - target_ship.get_defense/100.0)
        target_ship.update_columns(hp: target_ship.hp - attack.round)
        
        target_hp = target_ship.hp
        
        # If target hp is below 0 -> die
        if target_hp <= 0
          target_ship.update_columns(hp: 0)
          target.die and shutdown(player) and return
        end
        
        # Tell both parties to update their hp and log
        ac_server.broadcast("player_#{target_id}", method: 'update_health', hp: target_hp)
        ac_server.broadcast("player_#{target_id}", method: 'log', text: I18n.t('log.you_got_hit_hp', attacker: player_name, hp: attack))
        
        ac_server.broadcast("player_#{player_id}", method: 'update_target_health', hp: target_hp)
        ac_server.broadcast("player_#{player_id}", method: 'refresh_player_info')
        ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: target.full_name, hp: attack))
        
        # Tell other users who targeted target to also update hp
        User.where(target_id: target_id).where("online > 0").each do |u|
          ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target_hp)
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
    target.can_be_attacked and player.can_be_attacked and target.location == player.location and player.target == target and check_septarium(player, target)
  end
  
  def call_police(player, target)
    player_id = player.id
    
    if player.system.security_status != 'low' and Npc.where(npc_type: 'police', target: player_id).empty? and !target.in_same_fleet_as(player_id)
      if player.system.security_status == 'high'
        PoliceWorker.perform_async(player_id, 2)
      else
        PoliceWorker.perform_async(player_id, 10)
      end
    end
  end
  
  def shutdown(player)
    player.active_spaceship.deactivate_equipment
    player.update_columns(is_attacking: false)
  end
  
  def check_septarium(player, target)
    if player.active_spaceship.get_septarium_usage > player.active_spaceship.get_septarium 
      if player.is_attacking
        player.update_columns(is_attacking: false)
        ActionCable.server.broadcast("player_#{target.id}", method: 'getting_attacked', name: player.full_name)
      end
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
      ActionCable.server.broadcast("player_#{player.id}", method: 'show_error', text: I18n.t('errors.not_enough_septarium'))
      shutdown(player) and return false
    end
    true
  end
  
end