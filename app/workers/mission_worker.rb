class MissionWorker
  # This Worker will be run when a warps to an enemy hive
  
  include Sidekiq::Worker
  sidekiq_options :retry => false 
  
  def perform(location_id, player_id)
    location = Location.find(location_id) rescue nil
    
    # Get amount of enemies to spawn
    amount = location.mission.enemy_amount
    
    if amount > 0
      rounds = rand(3..5)
      wave_amount = (amount / rounds).round
      
      rounds.times do
        location = location.reload rescue nil
        spawn_enemies(wave_amount, location, location.mission.difficulty) if location
      end
    end
  end
  
  def spawn_enemies(wave_amount, location, difficulty)
    
    # set to 1
    wave_amount = 1 if wave_amount == 0
    
    wave_amount.times do
      EnemyWorker.perform_async(location.id, 2, difficulty) if location.users.count > 0
    end
    
    while true do
      sleep(10)
      return if (location.reload.npcs.count rescue 0) == 0
    end
  end
end