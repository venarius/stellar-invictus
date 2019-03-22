class TargetingWorker
  # This worker will be run whenever a player targets another

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(player_id, target_id, round = 0, max_rounds = 0)
    player = User.find(player_id)
    target = User.find(target_id)

    if max_rounds == 0

      # Remove mining and npc target
      player.update_columns(mining_target_id: nil, npc_target_id: nil)

      # Disable equipment
      player.active_spaceship.deactivate_equipment

      # Untarget old target if player is targeting new target
      if (player.target_id != nil) && (player.target_id != target_id)
        ActionCable.server.broadcast("player_#{player.target_id}", method: 'stopping_target', name: player.full_name)
        player.update_columns(target_id: nil)
      end

      # Get max rounds
      max_rounds = player.active_spaceship.get_target_time

      TargetingWorker.perform_in(1.second, player_id, target_id, round + 1, max_rounds) && (return)

    # Look every second if player docked or warped to stop targeting counter
    elsif round < max_rounds
      unless target.reload.can_be_attacked && (target.location == player.location) && player.reload.can_be_attacked && (player.mining_target_id == nil) && (player.npc_target_id == nil) && (player.target_id == nil)
        ActionCable.server.broadcast("player_#{target.id}", method: 'stopping_target', name: player.full_name) if round > 2
        return
      end

      # Broadcast Targeting
      ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name)

      TargetingWorker.perform_in(1.second, player_id, target_id, round + 1, max_rounds) && (return)
    else

      # Target player
      player.update_columns(target_id: target.id)
      ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
    end
  end
end
