class Npc < ApplicationRecord
  belongs_to :location, optional: true
  
  enum npc_type: [:enemy, :police]
  
  # Lets the npc die
  def die
    NpcDiedWorker.perform_async(self.id)
  end
  
  # Lets the npc drop loot
  def drop_loot
    loader = ASTEROIDS + MATERIALS
    structure = Structure.create(location: self.location, structure_type: 'wreck')
    rand(1..2).times do
      Item.create(loader: loader.sample, structure: structure, equipped: false)
    end
  end
  
  # Remove the npc from being targeted
  def remove_being_targeted
    User.where(npc_target_id: self.id).each do |user|
      user.update_columns(npc_target_id: nil, is_attacking: false)
      ActionCable.server.broadcast("player_#{user.id}", method: 'refresh_target_info')
    end
  end
  
  # Give bounty to player
  def give_bounty(player)
    
    value = rand(5..15)
    
    value = value * 3 if self.location.system.security_status == 'low'
    
    player.update_columns(units: player.units + value)
    
    ActionCable.server.broadcast("player_#{player.id}", method: 'notify_alert', text: I18n.t('notification.received_bounty', user: self.full_name, amount: value))
    ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_player_info')
  end
end
