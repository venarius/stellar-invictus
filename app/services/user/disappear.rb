class User::Disappear < ApplicationService
  required :user, ensure: ::User

  optional :remove_logout

  def perform
    # Remove logout timer
    user.update(logout_timer: false) if remove_logout

    # Remove 1 from user's online count
    user.decrement!(:online) if user.is_online?

    # If user is not docked and now closed last connection
    if user.online == 0

      # If user is not docked
      if !user.docked
        # Tell everyone in location that user warped out
        user.location.broadcast(:player_warp_out, name: user.full_name)

        # Drop Loot if Combatlogging
        if User.where(target: user, is_attacking: true).exists?
          user.active_spaceship.drop_loot
          user.location.broadcast(:player_appeared)
        end

        # Remove user as target from every player that targeted him
        user.remove_being_targeted
      end

      # Remove Targets
      user.update(
        target_id: nil,
        mining_target_id: nil,
        npc_target_id: nil,
        is_attacking: false
      )

      # Tell everyone in system to update their local players
      cur_system = user.location.system
      cur_system.update_local_players unless cur_system.wormhole?

      # Tell all users in custom chat channels to update
      user.chat_rooms.where(chatroom_type: [:custom, :corporation]).each do |room|
        room.update_local_players
      end
    end
  end

end
