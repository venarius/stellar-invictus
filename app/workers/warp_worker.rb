class WarpWorker
  # This worker will be run when a player warps to another location
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id)
    user = User.find(player_id)
    ship = user.active_spaceship
    
    # Get alignment time
    align_time = ship.get_align_time
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    # Remove warp target if same target
    ship.update_columns(warp_target_id: nil) and return if ship.warp_target_id == location_id
    
    # Set warp target
    ship.update_columns(warp_target_id: location_id)
    
    # Alignment
    align_time.times do
      user = user.reload
      ship = ship.reload
      
      return if !user.can_be_attacked || ship.warp_scrambled || ship.warp_target_id != location_id
      sleep(1)
    end
    
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
    
    # Unset warp_target_id
    ship.update_columns(warp_target_id: nil)
    
    # Tell everyone in new system that player has appeared
    ac_server.broadcast("location_#{user.location.id}", method: 'player_appeared')
    
    # Tell user to reload page
    ac_server.broadcast("player_#{user.id}", method: 'reload_page')
  end
end