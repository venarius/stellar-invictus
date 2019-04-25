class EquipmentWorker < ApplicationWorker
  # This Worker will be run when a player uses equipment

  def perform(player_id)
    # Get the Player and ship
    player = User.ensure(player_id)
    return unless player
    debug_args(player_id: player&.id)

    # Set Player status to using equipment worker
    player.update(equipment_worker: true)

    # Equipment Cycle
    while true do
      # Target Ship
      target_ship = player.target&.ship || player.npc_target
      target_id = player.target&.id || player.npc_target_id

      # Reload Player
      player.reload
      power = player.ship.get_power
      self_repair = player.ship.get_selfrepair
      remote_repair = player.ship.get_remoterepair

      # If is attacking else
      if (power > 0 ||
         player.ship.has_active_warp_disruptor) ||
         (power > 0 && remote_repair > 0)

        # If player is targeting user -> Call Police and Broadcast
        if player.target
          call_police(player) unless (player.target.target_id == player.id) && player.target.is_attacking
          target.broadcast(:getting_attacked, name: player.full_name)
        end

        # Set Attacking to True
        player.update(is_attacking: true) if !player.is_attacking

      elsif (power == 0) && (remote_repair == 0) && !player.ship.has_active_warp_disruptor && player.is_attacking

        # Set Attacking to False
        player.update(is_attacking: false)

        # If player had user targeted -> stop
        if player.target
          target.broadcast(:stopping_attack, name: player.full_name)
        end

        # Shutdown if repair also 0
        shutdown(player) && (return) if (self_repair == 0) && (remote_repair == 0)

      elsif remote_repair > 0
        # If player is targeting user -> Broadcast
        if player.target
          player.target.broadcast(:getting_helped, name: player.full_name)
        end

        # Set Attacking to True
        player.update(is_attacking: true) if !player.is_attacking
      end

      # If Repair -> repair
      if self_repair > 0
        if player.ship.hp < player.ship.get_max_hp

          if player.ship.hp + self_repair > player.ship.get_max_hp
            player.ship.update(hp: player.ship.get_max_hp)
          else
            player.ship.update(hp: player.ship.hp + self_repair)
          end

          player.broadcast(:update_health, hp: player.ship.hp)

          User.where(target_id: player_id).is_online.each do |u|
            u.broadcast(:update_target_health, hp: player.ship.hp)
          end
        else
          player.ship.deactivate_selfrepair_equipment
          self_repair = 0
          player.broadcast(:disable_equipment)
        end
      end

      # If player can attack target or remote repair
      if ((power > 0) && target_ship) || ((remote_repair > 0) && target_ship)

        if can_attack?(player)

          # The attack
          attack = power
          attack *= (1.0 - target_ship.get_defense / 100.0) if player.target

          target_ship.update(hp: target_ship.reload.hp - attack.round + remote_repair)

          if player.target
            target_ship.update(hp: target_ship.get_max_hp) if target_ship.hp > target_ship.get_max_hp
          end

          target_hp = target_ship.hp

          # Tell both parties to update their hp and log
          if player.target
            target.broadcast(:update_health, hp: target_hp)
            target.broadcast(:log, text: I18n.t('log.you_got_hit_hp', attacker: player.full_name, hp: attack.round))
            player.broadcast(:log,  text: I18n.t('log.you_hit_for_hp', target: player.target.full_name, hp: attack.round))
          elsif player.npc_target
            player.broadcast(:log, text: I18n.t('log.you_hit_for_hp', target: player.npc_target.name, hp: attack.round))
          end

          # Tell other users who targeted target to also update hp
          if player.target
            User.where(target_id: target_id).is_online.each do |u|
              u.broadcast(:update_target_health, hp: target_hp)
            end
            if player.target.fleet
              ChatChannel.broadcast_to(player.target.fleet.chat_room, method: 'update_hp_color', color: target_ship.get_hp_color, id: player.target.id)
            end
          elsif player.npc_target
            User.where(npc_target_id: target_id).is_online.each do |u|
              u.broadcast(:update_target_health, hp: target_hp)
            end
          end

          # If target hp is below 0 -> die
          if target_hp <= 0
            target_ship.update(hp: 0)
            if player.target
              player.target.give_bounty(player)
              # Remove user from being targeted by others
              attackers = User.where(target_id: player.target.id, is_attacking: true).pluck(:id)
              player.target.remove_being_targeted
              player.target.die(false, attackers)
              player.ship.deactivate_weapons
            else
              begin
                if (npc = player.npc_target) # assignment
                  npc.give_bounty(player)
                  # Remove npc from being targeted by others
                  npc.remove_being_targeted
                  npc.drop_blueprint if player.system.wormhole? && (rand(1..100) == 100)
                  npc.die
                end
                player.ship.deactivate_weapons
              rescue # Should _really_ define the exception you're expecting here
                shutdown(player)
                return
              end
            end
          end

        else
          disable_equipment(player)
          return
        end

      end

      # Rescue Global
      if (power == 0) && (self_repair == 0) && (remote_repair == 0) &&
        (!player.ship.has_active_warp_disruptor || !player.can_be_attacked?)

        disable_equipment(player)
        return
      end

      # Global Cooldown
      EquipmentWorker.perform_in(2.second, player.id)
    end
  end

  def disable_equipment(player)
    debug_args(:disable_equipment, player: player.id)

    player.broadcast(:disable_equipment)
    shutdown(player)
  end

  def shutdown(player)
    debug_args(:shutdown, player: player.id)

    player.ship.deactivate_equipment
    player.update(is_attacking: false, equipment_worker: false)
  end

  def call_police(player)
    debug_args(:call_police, player: player.id)

    if !player.system.low? &&
      !player.system.wormhole? &&
      !Npc.police.targeting_user(player).exists? &&
      !player.target.in_same_fleet_as(player)

      if player.system..high?
        PoliceWorker.perform_async(player.id, 2)
      else
        # TODO: Maybe have police respond in a random amount of time (5..15)?
        PoliceWorker.perform_async(player.id, 10)
      end
    end
  end

  def can_attack?(player)
    debug_args(:can_attack?, player: player.id)

    player.reload

    if player.target
      # Get Target
      target = player.target
      # Return true if both can be attacked, are in the same location and player has target locked on
      target.can_be_attacked? && player.can_be_attacked? && (target.location_id == player.location_id) && (player.target_id == target.id)
    elsif player.npc_target
      # Get Target
      target = player.npc_target
      # Return true if both can be attacked, are in the same location and player has target locked on
      player.can_be_attacked? && (target.hp > 0) && (target.location_id == player.location_id) && (player.npc_target_id == target.id)
    else
      false
    end
  end

end
