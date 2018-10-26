class WarpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id)
    User.find(player_id).update_columns(in_warp: true)
    sleep(10)
    User.find(player_id).update_columns(location_id: location_id, in_warp: false)
  end
end