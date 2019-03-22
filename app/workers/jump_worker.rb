class JumpWorker
  # This worker will be run whenever a user jumps through a jumpgate

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(player_id, in_jump = false, custom_traveltime = nil, custom_system = nil)
    user = User.find(player_id)
    old_system = user.system

    # Get ActionCable Server
    ac_server = ActionCable.server

    unless in_jump

      # Make user in warp and loose its target
      user.update_columns(in_warp: true, target_id: nil, is_attacking: false, npc_target_id: nil, mining_target_id: nil)

      # Tell everyone in location that user warped out
      ac_server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
      ac_server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_jumped_out', user: user.full_name, location: user.location.get_name))

      # Remove user from being targeted by others
      user.remove_being_targeted

      # Disable Equipment of user
      user.active_spaceship.deactivate_equipment

      # Sleep for the given traveltime by the jumpgate
      custom_traveltime ? JumpWorker.perform_in(custom_traveltime, player_id, true, nil, custom_system) : JumpWorker.perform_in(user.location.jumpgate.traveltime.second, player_id, true)

    else

      # Routing Stuff
      if user.route && !custom_traveltime
        user.update_columns(route: user.route - [user.location.jumpgate.id.to_s]) rescue true
      end

      # Set user system to new system
      if custom_system
        to_system = System.find(custom_system) rescue nil
        new_loc = to_system.locations.where(location_type: :jumpgate).first rescue nil
      else
        if user.location == user.location.jumpgate.origin
          to_system = System.find(user.location.jumpgate.destination.system_id) rescue nil
        else
          to_system = System.find(user.location.jumpgate.origin.system_id) rescue nil
        end
        new_loc = Location.find_by(name: old_system.name, system_id: to_system.id) rescue nil
      end

      # Check for to_system
      user.update_columns(in_warp: false) && ac_server.broadcast("player_#{user.id}", method: 'warp_finish', local: false) && (return) unless to_system && new_loc

      user.update_columns(system_id: to_system.id,
                          location_id: new_loc.id,
                          in_warp: false)

      # Set Variable
      user_system = user.system

      # Tell everyone in new location that user has appeared
      ac_server.broadcast("location_#{user.reload.location_id}", method: 'player_appeared')

      # Tell everyone in old system to update their local players
      old_system.update_local_players unless old_system.wormhole?

      # Tell everyone in new system to update their local players
      user_system.update_local_players unless user_system.wormhole?

      # Tell user to reload page
      ac_server.broadcast("player_#{user.id}", method: 'warp_finish', local: false)

    end
  end
end
