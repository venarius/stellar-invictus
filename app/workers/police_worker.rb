class PoliceWorker < ApplicationWorker
  # This worker simulates the police
  DEFAULT_UPDATE_SECONDS = 3

  def perform(player_id, seconds = nil, police_id = nil, idle = false, done = false)
    debug_args(player_id: player_id, seconds: seconds, police_id: police_id, idle: idle, done: done)

    player = User.ensure(player_id)
    return unless player

    location = player.location

    if police_id.present?
      police = Npc.ensure(police_id)
      return unless police
    end

    seconds ||= DEFAULT_UPDATE_SECONDS

    if police_id == nil
      police = Npc.create(npc_type: :police, target: player, name: generate_name)

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
