class PoliceWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, seconds)
    player = User.find(player_id)
    location = player.location
    
    police = Npc.create(npc_type: 'police', target: player.id)
    
    sleep(seconds)
    
    police.update_columns(location_id: location.id)
    
    # Tell everyone in the location that police has come
    ActionCable.server.broadcast("location_#{location.id}", method: 'player_appeared')
    
    sleep(2)
    
    # Tell user he is getting targeted by police
    ActionCable.server.broadcast("player_#{player.id}", method: 'getting_targeted', name: 'Police')
    
    sleep(3)
    
    # Tell user he is getting attacked by police
    ActionCable.server.broadcast("player_#{player.id}", method: 'getting_attacked', name: 'Police')
    
    sleep(1)
    
    # Let user die
    player.die
    
    sleep(3)
    
    # Let police warp out
    police.update_columns(location_id: nil)
    ActionCable.server.broadcast("location_#{location.id}", method: 'player_warp_out', name: 'Police')
    
    sleep(1)
    
    # Destroy police
    police.destroy
  end
  
end