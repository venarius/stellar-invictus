class JumpWorker
  # This worker will be run whenever a user jumps through a jumpgate
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    old_system = user.system
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    # Make user in warp and loose its target
    user.update_columns(in_warp: true, target_id: nil, is_attacking: false, npc_target_id: nil, mining_target_id: nil)
    
    # Tell everyone in location that user warped out
    ac_server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    ac_server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_jumped_out', user: user.full_name, location: user.location.name))
    
    # Remove user from being targeted by others
    user.remove_being_targeted
    
    # Sleep for the given traveltime by the jumpgate
    sleep(user.location.jumpgate.traveltime)
    
    # Set user system to new system
    to_system = System.find_by(name: user.location.name)
    user.update_columns(system_id: to_system.id, location_id: Location.find_by(location_type: 'jumpgate', name: old_system.name, system: to_system.id).id, in_warp: false)
    
    # Set Variable
    user_system = user.system
    
    # Tell everyone in new location that user has appeared
    ac_server.broadcast("location_#{user.reload.location_id}", method: 'player_appeared')
    
    # Tell everyone in old system to update their local players
    old_system.update_local_players
    
    # Tell everyone in new system to update their local players
    user_system.update_local_players
    
    # Tell user to reload page
    ac_server.broadcast("player_#{user.id}", method: 'reload_page')
  end
end