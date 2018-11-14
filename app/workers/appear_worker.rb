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
      
      # Tell everyone in system to update their local players
      user.system.locations.each do |location|
        ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
          count: User.where("online > 0").where(system: user.system).count, 
          names: User.where("online > 0").where(system: user.system).map(&:full_name))
      end
      
    end
  end
end