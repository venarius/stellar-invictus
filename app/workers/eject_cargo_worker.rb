class EjectCargoWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
   
  def perform(user_id, loader)
    user = User.find(user_id)
    
    
    items = Item.where(loader: loader, spaceship: user.active_spaceship)
    if items.present?
      structure = Structure.create(structure_type: 'container', location: user.location, user: user)
      items.update_all(structure_id: structure.id, user_id: nil, spaceship_id: nil)
      
      # Tell everyone at location to refresh players 
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      
      # Tell user to update player info
      ActionCable.server.broadcast("player_#{user.id}", method: 'refresh_player_info')
    end
  end
end