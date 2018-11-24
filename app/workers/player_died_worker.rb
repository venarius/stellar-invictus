class PlayerDiedWorker
  # This worker will be run whenever a player died
  
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    old_system = user.system
    
    # Get ActionCable Server
    ac_server = ActionCable.server
    
    # Tell others in system that player "warped out"
    ac_server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    ac_server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.got_killed', name: user.full_name) )
    
    # Create Wreck and fill with random loot
    user.active_spaceship.drop_loot
    ac_server.broadcast("location_#{user.location.id}", method: 'player_appeared')
    
    # Destroy current spaceship of user and give him a nano
    Spaceship.find(user.active_spaceship_id).destroy
    ship = Spaceship.create(user_id: user.id, name: 'Nano', hp: 50)
    Item.create(loader: 'equipment.miner.basic_miner', spaceship: ship, equipped: true)
    Item.create(loader: 'equipment.weapons.laser_gatling', spaceship: ship, equipped: true)
    
    # Make User docked at his factions station
    user.update_columns(docked: true, location_id: user.faction.location.id, system_id: user.faction.location.system.id, active_spaceship_id: ship.id, target_id: nil, mining_target_id: nil, npc_target_id: nil)
    
    # Tell user to reload page
    ac_server.broadcast("player_#{user.id}", method: 'reload_page')
    
    # Remove user from being targeted by others
    user.remove_being_targeted
    
    # Tell everyone in new system to update their local players
    old_system.update_local_players
    
    sleep(1)
    
    # Tell user to show died modal
    ac_server.broadcast("player_#{user.id}", method: 'died_modal', text: I18n.t('modal.died_text', location: "#{user.location.name} - #{user.system.name}") )
  end
end