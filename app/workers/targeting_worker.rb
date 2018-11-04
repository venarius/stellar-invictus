class TargetingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = User.find(target_id)
    
    # If target is already target -> untarget
    if player.target_id == target.id 
      player.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name)
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
      return
    end
    
    # Look every second if player docked or warped to stop targeting counter
    count = 0
    5.times do
      sleep(1)
      count = count +1
      unless target.reload.can_be_attacked and target.location == player.location and player.reload.can_be_attacked
        return
      end
      if count == 2
        ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name)
      end
    end
    
    # Target player
    if target.reload.can_be_attacked and target.location == player.location and player.reload.can_be_attacked
        player.update_columns(target_id: target.id)
        ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
    end
  end
end