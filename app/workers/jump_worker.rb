class JumpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    user.update_columns(in_warp: true)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    sleep(user.location.jumpgate.traveltime-1)
    to_system = System.where(name: user.location.name).first
    user.update_columns(system_id: to_system.id, location_id: Location.where(location_type: 'jumpgate', name: user.system.name, system: to_system.id).first.id, in_warp: false)
    ActionCable.server.broadcast("location_#{user.reload.location_id}", method: 'player_appeared')
  end
end