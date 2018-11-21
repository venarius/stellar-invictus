class NpcDiedWorker
  # This worker will be run whenever a npc died
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(npc_id)
    npc = Npc.find(npc_id) rescue nil
    
    if npc
      # Tell others in system that player "warped out" and log
      ActionCable.server.broadcast("location_#{npc.location.id}", method: 'player_warp_out', name: npc.name)
      ActionCable.server.broadcast("location_#{npc.location.id}", method: 'log', text: I18n.t('log.got_killed', name: npc.name) )
      
      # Create Wreck and fill with random loot
      npc.drop_loot
      ActionCable.server.broadcast("location_#{npc.location.id}", method: 'player_appeared')
      
      # Destroy current spaceship of user and give him a nano
      npc.destroy
      
      # Remove npc from being targeted by others
      npc.remove_being_targeted
    end
  end
end