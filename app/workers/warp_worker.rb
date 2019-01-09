class WarpWorker
  # This worker will be run when a player warps to another location
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id, location_id, align_current=0, align_time=0, in_warp=false)
    user = User.find(player_id)
    ship = user.active_spaceship
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    if align_time == 0
      # Get alignment time
      align_time = ship.get_align_time
      
      # Remove warp target if same target
      ship.update_columns(warp_target_id: nil) and return if ship.warp_target_id == location_id
      
      # Set warp target
      ship.update_columns(warp_target_id: location_id)
      
      WarpWorker.perform_in(1.second, player_id, location_id, align_current + 1, align_time) and return
    
    elsif align_current < align_time
      user = user.reload
      ship = ship.reload
      
      return if !user.can_be_attacked || ship.warp_scrambled || ship.warp_target_id != location_id
      WarpWorker.perform_in(1.second, player_id, location_id, align_current + 1, align_time) and return
    
    elsif !in_warp
    
      # Make user in warp and loose its target / mining target
      user.update_columns(in_warp: true, target_id: nil, mining_target_id: nil, npc_target_id: nil, is_attacking: false)
      
      # Tell everyone in location that user warped out
      ac_server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
      ac_server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_warped_out', user: user.full_name, location: Location.find(location_id).name))
      
      # Remove user from being targeted
      user.remove_being_targeted
      
      # Disable Equipment of user
      user.active_spaceship.deactivate_equipment
    
      # Sleep for global warp time, which is 10
      WarpWorker.perform_in(10.second, player_id, location_id, align_current, align_time, true) and return
      
    else
    
      # Set users location to new location
      user.update_columns(location_id: location_id, in_warp: false)
      
      # Unset warp_target_id
      ship.update_columns(warp_target_id: nil)
      
      # Tell everyone in new system that player has appeared
      ac_server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      
      # Tell user to reload page
      ac_server.broadcast("player_#{user.id}", method: 'warp_finish')
      
      # Start Mission Worker if location is mission and user has mission
      if user.location_location_type == 'mission' and user.location.mission.user == user
        MissionWorker.perform_async(user.location.id)
      end
      
      # Spawn Enemies if User at Expedtion Site with Enemies
      if user.location_location_type == 'exploration_site' and user.location_enemy_amount > 0
        (user.location_enemy_amount).times do
          EnemyWorker.perform_async(nil, user.location.id)
        end
      end
      
    end
  end
end
