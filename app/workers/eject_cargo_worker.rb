class EjectCargoWorker
  # This worker will be run when the user ejects cargo
  
  include Sidekiq::Worker
  sidekiq_options :retry => false
   
  def perform(user_id, loader, amount)
    user = User.find(user_id)
    
    
    item = Item.find_by(loader: loader, spaceship: user.active_spaceship, equipped: false, active: false)
    if item and amount
      structure = Structure.create(structure_type: 'container', location: user.location, user: user)
      
      if amount == item.count
        item.update_columns(structure_id: structure.id, user_id: nil, spaceship_id: nil, equipped: false)
      else
        item.update_columns(count: item.count - amount)
        Item.create(structure: structure, loader: item.loader, count: amount)
      end
      
      # Tell everyone at location to refresh players and log the eject
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_ejected_cargo', user: user.full_name) )
      
      # Tell user to update player info
      ActionCable.server.broadcast("player_#{user.id}", method: 'refresh_player_info')
    end
  end
end