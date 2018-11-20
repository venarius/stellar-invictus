class AppearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id) rescue nil
    if user
      system = user.system
      
      # Add 1 to user online status
      user.update_columns(online: user.online + 1)
      
      # If only connection and user is not docked
      if user.online == 1 and !user.docked
        # Tell everyone in the location that user has logged in
        ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      end
      
      # Tell everyone in system to update their local players
      users = User.where("online > 0").where(system: system)
      systen.locations.each do |location|
        ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
          count: users.count, names: users.map(&:full_name))
      end
      
      # Tell all users in custom chat channels to update
      user.chat_rooms.where(chatroom_type: 'custom').each do |room|
        ChatChannel.broadcast_to(room, method: 'update_players', names: room.users.where("online > 0").map(&:full_name))
      end
      
    end
  end
end