class TargetingWorker < ApplicationWorker
  # This worker will be run whenever a player targets another
  def perform(player, target, round = 0, max_rounds = 0)
    player = User.ensure(player)
    target = User.ensure(target)

    if max_rounds == 0

      # Remove mining and npc target
      player.update(mining_target_id: nil, npc_target_id: nil)

      # Disable equipment
      player.active_spaceship.deactivate_equipment

      # Untarget old target if player is targeting new target
      if (player.target_id != nil) && (player.target_id != target_id)
        player.target.broadcast(:stopping_target, name: player.full_name)
        player.update(target_id: nil)
      end

      # Get max rounds
      max_rounds = player.active_spaceship.get_target_time

      TargetingWorker.perform_in(1.second, player.id, target.id, round + 1, max_rounds)

    # Look every second if player docked or warped to stop targeting counter
    elsif round < max_rounds
      if !target.reload.can_be_attacked? ||
        (target.location != player.location) ||
        !player.reload.can_be_attacked? ||
        (player.mining_target_id != nil) ||
        (player.npc_target_id != nil) ||
        (player.target_id != nil)

        target.broadcast(:stopping_target, name: player.full_name) if round > 2
        return
      end

      # Broadcast Targeting
      target.broadcast(:getting_targeted, name: player.full_name)
      TargetingWorker.perform_in(1.second, player.id, target.id, round + 1, max_rounds)
    else
      # Target player
      player.update(target: target)
      player.broadcast(:refresh_target_info)
    end
  end
end
