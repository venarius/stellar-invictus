class DisappearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    if user and user.online
      user.update_columns(online: false)
      unless user.docked
        ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
        User.where(target_id: user.id).each do |u|
          u.update_columns(target_id: nil)
          ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
        end
      end
    end
  end
end