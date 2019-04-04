class NpcDiedWorker < ApplicationWorker
  def perform(npc_id)
    npc = Npc.ensure(npc_id)
    return unless npc

    # Tell others in system that npc "warped out" and log
    npc.location.broadcast(:player_warp_out, name: npc.name)
    npc.location.broadcast(:log, text: I18n.t('log.got_killed', name: npc.name))

    # Create Wreck and fill with random loot
    npc.drop_loot
    npc.location.broadcast(:player_appeared)

    # If npc was in mission location -> credit kill
    if npc.location.mission?
      if npc.location.mission.enemy_amount > 0
        npc.location.mission.update_columns(enemy_amount: npc.location.mission.enemy_amount - 1)
      end
    end

    # If npc was in combat site -> remove from amount
    if (npc.location.exploration_site?) && (npc.location.enemy_amount > 0)
      npc.location.update_columns(enemy_amount: npc.location.enemy_amount - 1)
    end

    # Destroy npc
    npc.destroy
  end
end
