class WarpWorker
  # This worker will be run when a player warps to another location
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id)
    user = User.find(player_id)
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    # Make user in warp and loose its target / mining target
    user.update_columns(in_warp: true, target_id: nil, mining_target_id: nil, is_attacking: false)
    
    # Tell everyone in location that user warped out
    ac_server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    ac_server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_warped_out', user: user.full_name, location: Location.find(location_id).name))
    
    # Remove user from being targeted
    user.remove_being_targeted
    
    # Sleep for global warp time, which is 10-1
    sleep(10)
    
    # Set users location to new location
    user.update_columns(location_id: location_id, in_warp: false)
    
    # Tell everyone in new system that player has appeared
    ac_server.broadcast("location_#{user.location.id}", method: 'player_appeared')
    
    # Tell user to reload page
    ac_server.broadcast("player_#{user.id}", method: 'reload_page')
  end
end