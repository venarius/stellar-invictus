class NpcDiedWorker
  # This worker will be run whenever a npc died

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(npc_id)
    npc = Npc.find(npc_id) rescue nil

    if npc

      # Tell others in system that npc "warped out" and log
      ActionCable.server.broadcast("location_#{npc.location.id}", method: 'player_warp_out', name: npc.name)
      ActionCable.server.broadcast("location_#{npc.location.id}", method: 'log', text: I18n.t('log.got_killed', name: npc.name))

      # Create Wreck and fill with random loot
      npc.drop_loot
      ActionCable.server.broadcast("location_#{npc.location.id}", method: 'player_appeared')

      # If npc was in mission location -> credit kill
      if npc.location_location_type == 'mission'
        if npc.location.mission.enemy_amount > 0
          npc.location.mission.update_columns(enemy_amount: npc.location.mission.enemy_amount - 1)
        end
      end

      # If npc was in combat site -> remove from amount
      if (npc.location_location_type == 'exploration_site') && (npc.location_enemy_amount > 0)
        npc.location.update_columns(enemy_amount: npc.location_enemy_amount - 1)
      end

      # Destroy npc
      npc.destroy
    end
  end
end
