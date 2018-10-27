class WarpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id)
    user = User.find(player_id)
    user.update_columns(in_warp: true)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    sleep(9)
    user.update_columns(location_id: location_id, in_warp: false)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
  end
end