class PlayerDiedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    old_system = user.system
    
    # Tell others in system that player "warped out"
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.got_killed', name: user.full_name) )
    
    # Create Wreck and fill with random loot
    user.active_spaceship.drop_loot
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
    
    # Destroy current spaceship of user and give him a nano
    Spaceship.find(user.active_spaceship_id).destroy
    ship = Spaceship.create(user_id: user.id, name: 'Nano', hp: 50)
    
    # Make User docked at his factions station
    user.update_columns(docked: true, location_id: user.faction.location.id, system_id: user.faction.location.system.id, active_spaceship_id: ship.id, target_id: nil, mining_target_id: nil, npc_target_id: nil)
    
    # Tell user to reload page
    ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
    
    # Remove user from being targeted by others
    User.where(target_id: user.id).each do |u|
      u.update_columns(target_id: nil, is_attacking: false)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
    
    # Tell everyone in new system to update their local players
    old_system.locations.each do |location|
      ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
        count: User.where("online > 0").where(system: user.system).count, 
        names: User.where("online > 0").where(system: user.system).map(&:full_name))
    end
    
    sleep(0.5)
    
    # Tell user to show died modal
    ActionCable.server.broadcast("player_#{user.id}", method: 'died_modal', text: I18n.t('modal.died_text', location: "#{user.location.name} - #{user.system.name}") )
  end
end