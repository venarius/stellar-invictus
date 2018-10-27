class DisappearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    if user and user.online
      user = User.find(player_id)
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
      user.update_columns(online: false)
    end
  end
end