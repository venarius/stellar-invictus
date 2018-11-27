class EquipmentWorker
  # This Worker will be run when a player uses equipment
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    # Get the Player and ship
    player = User.find(player_id)
    player_ship = player.active_spaceship
    player_name = player.full_name
    
    # Target Ship
    if player.target
      target_ship = player.target.active_spaceship
      target_id = player.target.id
    elsif player.npc_target
      target_ship = player.npc_target
      target_id = player.npc_target.id
    end
    
    # Check Septarium
    return if !check_septarium(player)
    
    # Set ActionCable Server
    ac_server = ActionCable.server
    
    # Equipment Cycle
    while true do
      
      # Reload Player
      player = player.reload
      
      # Get Power of Player
      power = player_ship.get_power
      
      # Get Repair Amount of Player
      repair = player_ship.get_repair
      
      # If is attacking else
      if (power > 0 || player_ship.has_active_warp_disruptor) and !player.is_attacking
        
        # If player is targeting user -> Call Police and Broadcast
        if player.target
          call_police(player)
          ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: player_name)
        end
        
        # Set Attacking to True
        player.update_columns(is_attacking: true)
        
      elsif power == 0 and !player_ship.has_active_warp_disruptor and player.is_attacking
      
        # Set Attacking to False
        player.update_columns(is_attacking: false)
      
        # If player had user targeted -> stop
        if player.target
          ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: player_name)
        end
        
        # Broadcast
        ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
        
        # Shutdown if repair also 0
        shutdown(player) and return if repair == 0
        
      end
    
      # Global Cooldown
      sleep(2)
      
      # If Repair -> repair
      if repair > 0 
        if player_ship.hp < player_ship.get_attribute('hp')
          
          # Septarium Check
          return if !check_septarium(player)
          
          # Remove septarium
          player.active_spaceship.use_septarium
            
          if player_ship.hp + repair > player_ship.get_attribute('hp')
            player_ship.update_columns(hp: player_ship.get_attribute('hp'))
          else
            player_ship.update_columns(hp: player_ship.hp + repair)
          end
          
          # Broadcast
          ac_server.broadcast("player_#{player_id}", method: 'update_health', hp: player_ship.hp)
          ac_server.broadcast("player_#{player_id}", method: 'refresh_player_info')
          
          User.where(target_id: player_id).where("online > 0").each do |u|
            ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: player_ship.hp)
          end
        else
          player.active_spaceship.deactivate_repair_equipment
          repair = 0
          ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
        end
      end
      
      # If player can attack target
      if power > 0
        
        if can_attack(player)
          
          # Remove septarium
          player.active_spaceship.use_septarium
          
          # The attack
          if player.target
            attack = power * (1.0 - target_ship.get_defense/100.0)
          else
            attack = power
          end
          
          target_ship.update_columns(hp: target_ship.hp - attack.round)
          
          target_hp = target_ship.hp
          
          # If target hp is below 0 -> die
          if target_hp <= 0
            target_ship.update_columns(hp: 0)
            if player.target
              player.target.die and shutdown(player) and return
            else
              player.npc_target.die and shutdown(player) and return
            end
          end
          
          # Tell both parties to update their hp and log
          if player.target
            ac_server.broadcast("player_#{target_id}", method: 'update_health', hp: target_hp)
            ac_server.broadcast("player_#{target_id}", method: 'log', text: I18n.t('log.you_got_hit_hp', attacker: player_name, hp: attack))
            ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: player.target.full_name, hp: attack))
          else
            ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: player.npc_target.name, hp: attack))
          end
          
          # Refresh for Septarium
          ac_server.broadcast("player_#{player_id}", method: 'refresh_player_info')
          
          # Tell other users who targeted target to also update hp
          if player.target
            User.where(target_id: target_id).where("online > 0").each do |u|
              ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target_hp)
            end
          else
            User.where(npc_target_id: target_id).where("online > 0").each do |u|
              ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target_hp)
            end
          end
          
        else 
        
          # Broadcast
          ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
        
          shutdown(player) and return
          
        end
        
      end
      
      # Rescue Global
      if power == 0 and repair == 0  and !player_ship.has_active_warp_disruptor || !player.can_be_attacked
        # Broadcast
        ac_server.broadcast("player_#{player_id}", method: 'refresh_target_info')
      
        shutdown(player) and return
      end
      
    end
    
  end
  
  # Septarium Check
  def check_septarium(player)
    # If player Septarium Usage is greater than what he has in Storage -> stop
    if player.active_spaceship.get_septarium_usage > player.active_spaceship.get_septarium 
      
      # If player is currently attacking -> stop
      ActionCable.server.broadcast("player_#{player.target.id}", method: 'getting_attacked', name: player.full_name) if player.is_attacking and player.target
      
      # Broadcast
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
      ActionCable.server.broadcast("player_#{player.id}", method: 'show_error', text: I18n.t('errors.not_enough_septarium'))
      
      # Shutdown
      shutdown(player) and return false
    end
    true
  end
  
  # Shutdown Method
  def shutdown(player)
    player.active_spaceship.deactivate_equipment
    player.update_columns(is_attacking: false)
  end
  
  # Call Police
  def call_police(player)
    player_id = player.id
    
    if player.system.security_status != 'low' and Npc.where(npc_type: 'police', target: player_id).empty? and !player.target.in_same_fleet_as(player_id)
      if player.system.security_status == 'high'
        PoliceWorker.perform_async(player_id, 2)
      else
        PoliceWorker.perform_async(player_id, 10)
      end
    end
  end
  
  # Can Attack Method
  def can_attack(player)
    player = player.reload
    
    if player.target
      # Get Target
      target = player.target
      # Return true if both can be attacked, are in the same location and player has target locked on
      target.can_be_attacked and player.can_be_attacked and target.location == player.location and player.target == target and check_septarium(player)
    elsif player.npc_target
      # Get Target
      target = player.npc_target
      # Return true if both can be attacked, are in the same location and player has target locked on
      player.can_be_attacked and target.hp > 0 and target.location == player.location and player.npc_target == target and check_septarium(player)
    else
      false
    end
  end
  
end