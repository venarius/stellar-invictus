class MissionWorker < ApplicationWorker
  # This Worker will be run when a warps to an enemy hive

  def perform(location_id, amount = 0, rounds = 0, wave_amount = 0)
    debug_args(location_id: location_id, amount: amount, rounds: rounds, wave_amount: wave_amount)

    location = Location.ensure(location_id)
    return unless location
    mission = location.mission

    # Get amount of enemies to spawn
    amount ||= location.mission&.enemy_amount
    amount = amount.to_i

    if amount > 0
      if (rounds == 0) && (wave_amount == 0) && location.mission.combat?
        rounds = rand(3..5)
        wave_amount = (amount / rounds).round
        wave_amount = 2 if wave_amount == 0 || wave_amount == 1
      elsif (rounds == 0) && (wave_amount == 0) && location.mission.vip?
        rounds = 1
        wave_amount = location.mission&.enemy_amount
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

  def spawn_enemies(wave_amount, location)
    debug_args(:spawn_enemies, wave_amount: wave_amount, location: location&.id)
    count = 0
    wave_amount.times do
      count += 1
      EnemyWorker.perform_async(nil, location.id, nil, nil, count)
    end
  end

end
