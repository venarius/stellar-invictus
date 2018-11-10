class PlayerDiedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(player_id)
    user = User.find(player_id)
    
    # Tell others in system that player "warped out"
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_warp_out', name: user.full_name)
    
    # Destroy current spaceship of user and give him a nano
    Spaceship.find(user.active_spaceship_id).destroy
    ship = Spaceship.create(user_id: user.id, name: 'Nano', hp: 50)
    
    # Make User docked at his factions station
    user.update_columns(docked: true, location_id: user.faction.location.id, system_id: user.faction.location.system.id, active_spaceship_id: ship.id, target_id: nil)
    
    # Tell user to reload page
    ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
    
    # Remove user from being targeted by others
    User.where(target_id: user.id).each do |u|
      u.update_columns(target_id: nil)
      ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
    end
  end
end