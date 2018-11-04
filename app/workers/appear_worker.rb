class AppearWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id) rescue nil
    if user
      # Add 1 to user online status
      user.update_columns(online: user.online + 1)
      
      # If only connection and user is not docked
      if user.online == 1 and !user.docked
        # Tell everyone in the location that user has logged in
        ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      end
    end
  end
end