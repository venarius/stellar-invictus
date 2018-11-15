class TargetNpcWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = Npc.find(target_id)
    
    # Untarget old target if player is targeting new target
    if player.target_id != nil
      ActionCable.server.broadcast("player_#{player.target_id}", method: 'getting_targeted', name: player.full_name)
      player.update_columns(target_id: nil)
    end
    
    # Remove mining target and npc target
    player.update_columns(mining_target_id: nil, npc_target_id: nil)
    
    # Look every second if player docked or warped to stop targeting counter
    5.times do
      sleep(1)
      return unless player.can_be_attacked and player.location == target.location and target.hp > 0 and player.mining_target_id == nil and player.target_id == nil and player.npc_target_id == nil
    end
    
    # Target npc
    player.update_columns(npc_target_id: target.id)
    ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
  end
end