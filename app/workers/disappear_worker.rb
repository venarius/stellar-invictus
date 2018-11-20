class DisappearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    system = user.system
    # Remove one from online
    online = user.online
    user.update_columns(online: online - 1) if online > 0
    
    # If user is not docked and now closed last connection
    if user.reload.online == 0
      unless user.docked
        # Tell everyone in location that user warped out
        ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
        
        # Remove user as target from every player that targeted him
        User.where(target_id: user.id).each do |useri|
          useri.update_columns(target_id: nil)
          ActionCable.server.broadcast("player_#{useri.id}", method: 'refresh_target_info')
        end
      end
      
      # Update user
      user.update_columns(target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
      
      # Tell everyone in system to update their local players
      users = User.where("online > 0").where(system: system)
      system.locations.each do |location|
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