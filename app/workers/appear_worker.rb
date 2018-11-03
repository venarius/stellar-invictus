class AppearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    if user and !user.online
      unless user.docked
        ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      end
      user.update_columns(online: true)
    end
  end
end