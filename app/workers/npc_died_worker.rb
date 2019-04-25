class NpcDiedWorker < ApplicationWorker
  def perform(npc_id)
    debug_args(npc: npc_id)
    npc = Npc.ensure(npc_id)
    return unless npc

    User.where(npc_target_id: npc.id).update_all(npc_target_id: nil)

    # Tell others in system that npc "warped out" and log
    npc.location.broadcast(:player_warp_out, name: npc.name)
    npc.location.broadcast(:log, text: I18n.t('log.got_killed', name: npc.name))

    # Create Wreck and fill with random loot
    npc.drop_loot
    npc.location.broadcast(:player_appeared)

    # If npc was in mission or combat location -> credit kill
    if %w[mission exploration_site].include?(npc.location.location_type)
      npc.location.mission.decrement!(:enemy_amount) if npc.location.mission.enemy_amount > 0
    end

    # Destroy npc
    npc.destroy
  end
end
