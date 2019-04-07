class JumpWorker < ApplicationWorker
  # This worker will be run whenever a user jumps through a jumpgate
  def perform(player_id, in_jump = false, traveltime = nil, custom_system = nil)
    player = User.ensure(player_id)
    old_system = player.system

    if in_jump
      # Routing Stuff
      if player.route && !traveltime
        player.update(route: player.route - [player.location.jumpgate.id.to_s]) rescue true
      end

      # Set user system to new system
      if custom_system
        to_system = System.ensure(custom_system)
        new_loc = to_system.locations.jumpgate.first
      else
        if player.location == player.location.jumpgate.origin
          to_system = System.ensure(player.location.jumpgate.destination.system_id)
        else
          to_system = System.ensure(player.location.jumpgate.origin.system_id)
        end
        new_loc = Location.where(name: old_system.name, system: to_system).first
      end

      # Check for to_system
      if !(to_system && new_loc)
        player.update(in_warp: false)
        player.broadcast(:warp_finish, local: false)
        return
      end

      player.update(system: to_system, location: new_loc, in_warp: false)

      # Set Variable
      user_system = player.system

      # Tell everyone in new location that user has appeared
      player.reload.location.broadcast(:player_appeared)

      # Tell everyone in old system to update their local players
      old_system.update_local_players unless old_system.wormhole?

      # Tell everyone in new system to update their local players
      user_system.update_local_players unless user_system.wormhole?

      # Tell user to reload page
      player.broadcast(:warp_finish, local: false)
    else # NOT IN JUMP
      # Make user in warp and loose its target
      player.update(in_warp: true, target_id: nil, is_attacking: false, npc_target_id: nil, mining_target_id: nil)

      # Tell everyone in location that user warped out
      player.broadcast(:player_warp_out, name: player.full_name)
      player.broadcast(:log, text: I18n.t('log.user_jumped_out', user: player.full_name, location: player.location.get_name))

      # Remove user from being targeted by others
      player.remove_being_targeted

      # Disable Equipment of user
      player.active_spaceship.deactivate_equipment

      # Sleep for the given traveltime by the jumpgate
      traveltime ||= player.location.jumpgate.traveltime
      JumpWorker.perform_in(traveltime.seconds, player.id, true, nil, custom_system)
    end
  end
end
