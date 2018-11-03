class WarpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id)
    user = User.find(player_id)
    user.update_columns(in_warp: true, target_id: nil)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    User.where(target_id: user.id).each do |u|
      u.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
    sleep(9)
    user.update_columns(location_id: location_id, in_warp: false)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
  end
end