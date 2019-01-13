class TargetNpcWorker
  # This worker will be run whenever a player targets an npc
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id, round=0, max_rounds=0)
    player = User.find(player_id)
    target = Npc.find(target_id) rescue nil
    
    return unless target
    
    if max_rounds == 0
      # Untarget old target if player is targeting new target
      if player.target_id != nil
        ActionCable.server.broadcast("player_#{player.target_id}", method: 'stopping_target', name: player.full_name)
        player.update_columns(target_id: nil)
      end
      
      # Remove mining target and npc target
      player.update_columns(mining_target_id: nil, npc_target_id: nil)
      
      # Get max rounds
      max_rounds = player.active_spaceship.get_target_time
      
      TargetNpcWorker.perform_in(1.second, player_id, target_id, round + 1, max_rounds) and return
    
    # Look every second if player docked or warped to stop targeting counter
    elsif round < max_rounds
      return unless player.can_be_attacked and player.location == target.location and target.hp > 0 and player.mining_target_id == nil and player.target_id == nil and player.npc_target_id == nil
      TargetNpcWorker.perform_in(1.second, player_id, target_id, round + 1, max_rounds) and return
    else
    
      # Target npc
      player.update_columns(npc_target_id: target.id)
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
    end
  end
end