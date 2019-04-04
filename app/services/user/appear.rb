class User::Appear < ApplicationService
  required :user, ensure: ::User

  def perform
    user.increment!(:online)
    notify_others
    handle_location(user.location)
  end

  private

  def notify_others
    # If only connection and user is not docked
    if (user.online == 1) && !user.docked?
      # Tell everyone in the location that user has logged in
      user.location.broadcast(:player_appeared)
    end

    # Tell everyone in system to update their local players
    user.system.update_local_players unless user.system.wormhole?

    # Tell all users in custom chat channels to update
    user.chat_rooms.where(chatroom_type: %i[custom corporation]).each do |room|
      room.update_local_players
    end
  end

  def handle_location(location)
    # Things to do based on User's current location
    case location.location_type
    when 'mission'
      # Start Mission Worker if location is mission and user has mission
      if location.mission.user == user
        MissionWorker.perform_async(location.id)
      end
    when 'exploration_site'
      # Spawn Enemies if User at Expedtion Site with Enemies
      if location.enemy_amount > 0 && !location.npcs.exists?
        location.enemy_amount.times do
          EnemyWorker.perform_async(nil, location.id)
        end
      end
    end
  end

end
