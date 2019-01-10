class DisappearWorker
  # This Worker will be run when the user loggs off
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id) rescue nil
    
    if user
      system = user.system
      
      # Remove 1 from user's online count
      online = user.online
      user.update_columns(online: online - 1) if online > 0
      
      # If user is not docked and now closed last connection
      if user.reload.online == 0
        # If user is not docked
        if !user.docked
          # Tell everyone in location that user warped out
          ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
          
          # Drop Loot if Combatlogging
          if User.where(target_id: player_id, is_attacking: true).count > 0
            user.active_spaceship.drop_loot
            ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
          end
  
          # Remove user as target from every player that targeted him
          user.remove_being_targeted
        end
        
        # Update user
        user.update_columns(target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
        
        # Tell everyone in system to update their local players
        system.update_local_players
        
        # Tell all users in custom chat channels to update
        user.chat_rooms.where(chatroom_type: 'custom').each do |room|
          room.update_local_players
        end
        user.chat_rooms.where(chatroom_type: 'corporation').each do |room|
          room.update_local_players
        end
      end
    end
      
  end
end