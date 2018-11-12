class NpcDiedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(npc_id)
    npc = Npc.find(npc_id)
    
    # Tell others in system that player "warped out"
    ActionCable.server.broadcast("location_#{npc.location.id}", method: 'player_warp_out', name: npc.name)
    
    # Destroy current spaceship of user and give him a nano
    npc.destroy
    
    # Remove npc from being targeted by others
    User.where(npc_target_id: npc.id).each do |u|
      u.update_columns(npc_target_id: nil)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
  end
end