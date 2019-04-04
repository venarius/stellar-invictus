class MissionWorker < ApplicationWorker
  # This Worker will be run when a warps to an enemy hive

  def perform(location, amount = 0, rounds = 0, wave_amount = 0)
    location = Location.ensure(location)
    if location
      # Get amount of enemies to spawn
      amount = location.mission_enemy_amount if amount == 0

      if amount > 0

        if (rounds == 0) && (wave_amount == 0) && location.mission.combat?
          rounds = rand(3..5)
          wave_amount = (amount / rounds).round
          wave_amount = 2 if wave_amount == 0 || wave_amount == 1
        elsif (rounds == 0) && (wave_amount == 0) && location.mission.vip?
          rounds = 1
          wave_amount = location.mission_enemy_amount
        end

        if location.users.count > 0
          if location.npcs.count == 0
            rounds = rounds - 1
            spawn_enemies(wave_amount, location)
          end

          if rounds > 0
            MissionWorker.perform_in(10.seconds, location.id, amount, rounds, wave_amount)
          end
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
