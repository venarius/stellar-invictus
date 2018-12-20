class MissionWorker
  # This Worker will be run when a warps to an enemy hive
  
  include Sidekiq::Worker
  sidekiq_options :retry => false 
  
  def perform(location_id, amount=0, rounds=0, wave_amount=0)
    location = Location.find(location_id) rescue nil
    
    if location
      # Get amount of enemies to spawn
      amount = location.mission.enemy_amount if amount == 0
      
      if amount > 0
        
        if rounds == 0 and wave_amount == 0 and location.mission.combat?
          rounds = rand(3..5)
          wave_amount = (amount / rounds).round
          wave_amount = 2 if wave_amount == 0 || wave_amount == 1
        elsif rounds == 0 and wave_amount == 0 and location.mission.vip?
          rounds = 1
          wave_amount = location.mission.enemy_amount
        end
        
        if location.users.count > 0
          if location.npcs.count == 0
            rounds = rounds - 1
            spawn_enemies(wave_amount, location)
          end
          
          MissionWorker.perform_in(10.seconds, location_id, amount, rounds, wave_amount) if rounds > 0
        end
        
      end
    end
  end
  
  def spawn_enemies(wave_amount, location)
    
    count = 0
    wave_amount.times do
      count = count + 1
      EnemyWorker.perform_async(nil, location.id, nil, nil, count)
    end
    
  end
  
end