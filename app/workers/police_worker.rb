class PoliceWorker < ApplicationWorker
  # This worker simulates the police
  DEFAULT_UPDATE_SECONDS = 3

  def perform(player, seconds, police_id = nil, idle = false, done = false)
    player = User.ensure(player)
    location = player.location
    police = Npc.ensure(police)
    return unless police if police_id
    seconds ||= DEFAULT_UPDATE_SECONDS

    if police_id == nil
      police = Npc.create(npc_type: :police, target_user: player, name: generate_name)

      PoliceWorker.perform_in(seconds.second, player.id, seconds, police.id)
      return
    end

    if police.npc_state.nil?
      police.update(location_id: location.id, npc_state: 'created')

      # Tell everyone in the location that police has come
      location.broadcast(:player_appeared)

      PoliceWorker.perform_in(2.second, player.id, seconds, police.id)
      return
    end

    if police.created?
      # Tell user he is getting targeted by police
      player.broadcast(:getting_targeted, name: police.name)
      police.targeting!

      PoliceWorker.perform_in(3.second, player.id, seconds, police.id)
      return
    end

    if police.targeting?
      # Tell user he is getting attacked by police
      player.broadcast(:getting_attacked, name: police.name)
      police.attacking!

      PoliceWorker.perform_in(3.second, player.id, seconds, police.id)
      return
    end

    if !idle
      # Let user die
      player.die(true)

      PoliceWorker.perform_in(3.second, player.id, seconds, police.id, true)
      return
    end

    if !done
      # Let police warp out
      police.location.broadcast(:player_warp_out, name: police.name)
      police.update(location: nil)

      PoliceWorker.perform_in(3.second, player.id, seconds, police.id, true, true)
      return
    end

    # Destroy police
    police.destroy
  end

  private

    TITLES = %w[Sergeant Marshall Officer Ranger"].freeze
    def generate_name
      "#{TITLES.sample} #{Faker::Name.last_name}"
    end

end
