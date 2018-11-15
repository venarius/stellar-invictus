class JumpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    old_system = user.system
    
    # Make user in warp and loose its target
    user.update_columns(in_warp: true, target_id: nil)
    
    # Tell everyone in location that user warped out
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_jumped_out', user: user.full_name, location: user.location.name))
    
    # Remove user from being targeted by others
    User.where(target_id: user.id).each do |u|
      u.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
    
    # Sleep for the given traveltime by the jumpgate
    sleep(user.location.jumpgate.traveltime)
    
    # Set user system to new system
    to_system = System.find_by(name: user.location.name)
    user.update_columns(system_id: to_system.id, location_id: Location.find_by(location_type: 'jumpgate', name: user.system.name, system: to_system.id).id, in_warp: false)
    
    # Tell everyone in new location that user has appeared
    ActionCable.server.broadcast("location_#{user.reload.location_id}", method: 'player_appeared')
    
    # Tell everyone in old system to update their local players
    old_system.locations.each do |location|
      ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
        count: User.where("online > 0").where(system: old_system).count, 
        names: User.where("online > 0").where(system: old_system).map(&:full_name))
    end
    
    # Tell everyone in new system to update their local players
    user.system.locations.each do |location|
      ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
        count: User.where("online > 0").where(system: user.system).count, 
        names: User.where("online > 0").where(system: user.system).map(&:full_name))
    end
    
    # Tell user to reload page
    ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
  end
end