class AppearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id) rescue nil
    if user and !user.docked
      user.update_columns(online: true)
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
    end
  end
end