class EquipmentWorker
  # This Worker will be run when a player uses equipment

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(player_id)
    # Get the Player and ship
    player = User.find(player_id)

    # Set Player status to using equipment worker
    player.update_columns(equipment_worker: true)

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

    # Set ActionCable Server
    ac_server = ActionCable.server

    # Equipment Cycle
    while true do

      # Reload Player
      player = player.reload

      # Get Power of Player
      power = player_ship.get_power

      # Get Repair Amount of Player
      self_repair = player_ship.get_selfrepair
      remote_repair = player_ship.get_remoterepair

      # If is attacking else
      if  (power > 0 || player_ship.has_active_warp_disruptor) || ((power > 0) && (remote_repair > 0))

        # If player is targeting user -> Call Police and Broadcast
        if player.target
          call_police(player) unless (player.target.target_id == player.id) && player.target.is_attacking
          ac_server.broadcast("player_#{target_id}", method: 'getting_attacked', name: player_name)
        end

        # Set Attacking to True
        player.update_columns(is_attacking: true) if !player.is_attacking

      elsif (power == 0) && (remote_repair == 0) && !player_ship.has_active_warp_disruptor && player.is_attacking

        # Set Attacking to False
        player.update_columns(is_attacking: false)

        # If player had user targeted -> stop
        if player.target
          ac_server.broadcast("player_#{target_id}", method: 'stopping_attack', name: player_name)
        end

        # Shutdown if repair also 0
        shutdown(player) && (return) if (self_repair == 0) && (remote_repair == 0)

      elsif remote_repair > 0
        # If player is targeting user -> Broadcast
        if player.target
          ac_server.broadcast("player_#{target_id}", method: 'getting_helped', name: player_name)
        end

        # Set Attacking to True
        player.update_columns(is_attacking: true) if !player.is_attacking
      end

      # If Repair -> repair
      if self_repair > 0
        if player_ship.hp < player_ship.get_max_hp

          if player_ship.hp + self_repair > player_ship.get_max_hp
            player_ship.update_columns(hp: player_ship.get_max_hp)
          else
            player_ship.update_columns(hp: player_ship.hp + self_repair)
          end

          # Broadcast
          ac_server.broadcast("player_#{player_id}", method: 'update_health', hp: player_ship.hp)

          User.where(target_id: player_id).where("online > 0").each do |u|
            ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: player_ship.hp)
          end
        else
          player.active_spaceship.deactivate_selfrepair_equipment
          self_repair = 0
          ac_server.broadcast("player_#{player_id}", method: 'disable_equipment')
        end
      end

      # If player can attack target or remote repair
      if ((power > 0) && target_ship) || ((remote_repair > 0) && target_ship)

        if can_attack(player)

          # The attack
          if player.target
            attack = power * (1.0 - target_ship.get_defense / 100.0)
          else
            attack = power
          end

          target_ship.update_columns(hp: target_ship.reload.hp - attack.round + remote_repair)

          if player.target
            target_ship.update_columns(hp: target_ship.get_max_hp) if target_ship.hp > target_ship.get_max_hp
          end

          target_hp = target_ship.hp

          # Tell both parties to update their hp and log
          if player.target
            ac_server.broadcast("player_#{target_id}", method: 'update_health', hp: target_hp)
            ac_server.broadcast("player_#{target_id}", method: 'log', text: I18n.t('log.you_got_hit_hp', attacker: player_name, hp: attack.round))
            ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: player.target.full_name, hp: attack.round))
          elsif player.npc_target
            ac_server.broadcast("player_#{player_id}", method: 'log', text: I18n.t('log.you_hit_for_hp', target: player.npc_target.name, hp: attack.round))
          end

          # Tell other users who targeted target to also update hp
          if player.target
            User.where(target_id: target_id).where("online > 0").each do |u|
              ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target_hp)
            end
            if player.target.fleet
              ChatChannel.broadcast_to(player.target.fleet.chat_room, method: 'update_hp_color', color: target_ship.get_hp_color, id: player.target.id)
            end
          elsif player.npc_target
            User.where(npc_target_id: target_id).where("online > 0").each do |u|
              ac_server.broadcast("player_#{u.id}", method: 'update_target_health', hp: target_hp)
            end
          end

          # If target hp is below 0 -> die
          if target_hp <= 0
            target_ship.update_columns(hp: 0)
            if player.target
              player.target.give_bounty(player)
              # Remove user from being targeted by others
              attackers = User.where(target_id: player.target.id, is_attacking: true).pluck(:id)
              player.target.remove_being_targeted
              player.target.die(false, attackers) && player.active_spaceship.deactivate_weapons
            else
              begin
                player.npc_target.give_bounty(player)
                # Remove user from being targeted by others
                player.npc_target.remove_being_targeted
                player.npc_target.drop_blueprint if player.system.wormhole? && (rand(1..100) == 100)
                player.npc_target.die if player.npc_target
                player.active_spaceship.deactivate_weapons
              rescue
                shutdown(player) && (return)
              end
            end
          end

        else

          ActionCable.server.broadcast("player_#{player.id}", method: 'disable_equipment')
          shutdown(player) && (return)

        end

      end

      # Rescue Global
      if (power == 0) && (self_repair == 0) && remote_repair == 0 && !player_ship.has_active_warp_disruptor || !player.can_be_attacked
        # Broadcast
        ActionCable.server.broadcast("player_#{player.id}", method: 'disable_equipment')

        shutdown(player) && (return)
      end

      # Global Cooldown
      EquipmentWorker.perform_in(2.second, player.id) && (return)

    end

  end

  # Shutdown Method
  def shutdown(player)
    player.active_spaceship.deactivate_equipment
    player.update_columns(is_attacking: false, equipment_worker: false)
  end

  # Call Police
  def call_police(player)
    player_id = player.id

    if !player.system.low? && !player.system.wormhole? && Npc.where(npc_type: 'police', target: player_id).empty? && !player.target.in_same_fleet_as(player_id)
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
      target.can_be_attacked && player.can_be_attacked && (target.location == player.location) && (player.target == target)
    elsif player.npc_target
      # Get Target
      target = player.npc_target
      # Return true if both can be attacked, are in the same location and player has target locked on
      player.can_be_attacked && (target.hp > 0) && (target.location == player.location) && (player.npc_target == target)
    else
      false
    end
  end

end
