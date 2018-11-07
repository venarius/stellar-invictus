class TargetingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = User.find(target_id)
    
    # Remove mining target
    player.update_columns(mining_target_id: nil)
    
    # If target is already target -> untarget
    if player.target_id == target.id 
      player.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name)
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
      return
    end
    
    # Untarget old target if player is targeting new target
    if player.target_id != nil and player.target_id != target_id
      ActionCable.server.broadcast("player_#{player.target_id}", method: 'getting_targeted', name: player.full_name)
      player.update_columns(target_id: nil)
    end
    
    # Look every second if player docked or warped to stop targeting counter
    count = 0
    5.times do
      sleep(1)
      count = count + 1
      unless target.reload.can_be_attacked and target.location == player.location and player.reload.can_be_attacked and player.mining_target_id == nil
        ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name) if count > 2
        return
      end
      if count == 2
        ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name)
      end
    end
    
    # Target player
    if target.reload.can_be_attacked and target.location == player.location and player.reload.can_be_attacked and player.mining_target_id == nil
        player.update_columns(target_id: target.id)
        ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
    end
  end
end