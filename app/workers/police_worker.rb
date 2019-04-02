class PoliceWorker
  # This worker simulates the police

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(player_id, seconds, npc_id = nil, idle = false, done = false)
    player = User.find(player_id) rescue nil
    location = player.location
    police = Npc.find(npc_id) rescue nil if npc_id

    return unless police if npc_id

    if npc_id == nil
      police = Npc.create(npc_type: :police, target_user: player, name: generate_name)

      PoliceWorker.perform_in(seconds.second, player_id, seconds, police.id) && (return)
    end

    unless police.npc_state
      police.update_columns(location_id: location.id, npc_state: 'created')

      # Tell everyone in the location that police has come
      ActionCable.server.broadcast("location_#{location.id}", method: 'player_appeared')

      PoliceWorker.perform_in(2.second, player_id, seconds, police.id) && (return)
    end

    if police.created?
      # Tell user he is getting targeted by police
      ActionCable.server.broadcast("player_#{player.id}", method: 'getting_targeted', name: police.name)

      police.targeting!

      PoliceWorker.perform_in(3.second, player_id, seconds, police.id) && (return)
    end

    if police.targeting?
      # Tell user he is getting attacked by police
      ActionCable.server.broadcast("player_#{player.id}", method: 'getting_attacked', name: police.name)

      police.attacking!

      PoliceWorker.perform_in(3.second, player_id, seconds, police.id) && (return)
    end

    if !idle
      # Let user die
      player.die(true)

      PoliceWorker.perform_in(3.second, player_id, seconds, police.id, true) && (return)
    end

    if !done
      # Let police warp out
      ActionCable.server.broadcast("location_#{police.location.id}", method: 'player_warp_out', name: police.name)
      police.update_columns(location_id: nil)

      PoliceWorker.perform_in(3.second, player_id, seconds, police.id, true, true) && (return)
    end

    # Destroy police
    police.destroy
  end

  def generate_name
    title = ["Sergeant", "Marshall", "Officer"].sample
    "#{title} #{Faker::Name.last_name}"
  end

end
