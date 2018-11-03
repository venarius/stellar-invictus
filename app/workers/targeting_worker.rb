class TargetingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, target_id)
    player = User.find(player_id)
    target = User.find(target_id)
    sleep(2)
    ActionCable.server.broadcast("player_#{target.id}", method: 'getting_targeted', name: player.full_name)
    sleep(3)
    if target.can_be_attacked and target.location == player.location and player.can_be_attacked
        player.update_columns(target_id: target.id)
        ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_target_info')
    end
  end
end