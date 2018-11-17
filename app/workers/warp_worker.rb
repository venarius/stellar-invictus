class WarpWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id)
    user = User.find(player_id)
    
    # Make user in warp and loose its target / mining target
    user.update_columns(in_warp: true, target_id: nil, mining_target_id: nil, is_attacking: false)
    
    # Tell everyone in location that user warped out
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_warped_out', user: user.full_name, location: Location.find(location_id).name))
    
    # Remove user from being targeted
    User.where(target_id: user.id).each do |u|
      u.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
    
    # Sleep for global warp time, which is 10-1
    sleep(10)
    
    # Set users location to new location
    user.update_columns(location_id: location_id, in_warp: false)
    
    # Tell everyone in new system that player has appeared
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
    
    # Tell user to reload page
    ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
  end
end