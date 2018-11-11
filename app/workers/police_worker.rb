class PoliceWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, seconds)
    player = User.find(player_id)
    location = player.location
    
    police = Npc.create(npc_type: 'police', target: player.id, name: generate_name)
    
    sleep(seconds)
    
    police.update_columns(location_id: location.id)
    
    # Tell everyone in the location that police has come
    ActionCable.server.broadcast("location_#{location.id}", method: 'player_appeared')
    
    sleep(2)
    
    # Tell user he is getting targeted by police
    ActionCable.server.broadcast("player_#{player.id}", method: 'getting_targeted', name: police.name)
    
    sleep(3)
    
    # Tell user he is getting attacked by police
    ActionCable.server.broadcast("player_#{player.id}", method: 'getting_attacked', name: police.name)
    
    sleep(1)
    
    # Let user die
    player.die
    
    sleep(3)
    
    # Let police warp out
    police.update_columns(location_id: nil)
    ActionCable.server.broadcast("location_#{location.id}", method: 'player_warp_out', name: police.name)
    
    sleep(1)
    
    # Destroy police
    police.destroy
  end
  
  def generate_name
    title = ["Sergeant", "Marshall", "Officer"].sample
    "#{title} #{Faker::Name.last_name}"
  end
  
end