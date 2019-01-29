class Npc < ApplicationRecord
  belongs_to :location, optional: true
  
  enum npc_type: [:enemy, :police, :politician, :bodyguard, :wanted_enemy]
  enum npc_state: [:created, :targeting, :attacking, :waiting]
  
  delegate :location_type, :enemy_amount, :to => :location, :prefix => true
  
  # Lets the npc die
  def die
    NpcDiedWorker.perform_async(self.id)
  end
  
  # Lets the npc drop loot
  def drop_loot
    if self.location.location_type == 'exploration_site'
      loader = ASTEROIDS + MATERIALS
      case rand(1..100)
        when 1..75
          loader = EQUIPMENT_EASY + loader
        when 76..95
          loader = EQUIPMENT_MEDIUM + loader
        when 96..100
          loader = EQUIPMENT_HARD + loader
      end
    else
      loader = ASTEROIDS + MATERIALS
    end
    structure = Structure.create(location: self.location, structure_type: 'wreck')
    rand(1..3).times do
      Item.create(loader: loader.sample, structure: structure, equipped: false)
    end
  end
  
  # Remove the npc from being targeted
  def remove_being_targeted
    User.where(npc_target_id: self.id).each do |user|
      user.update_columns(npc_target_id: nil, is_attacking: false)
      ActionCable.server.broadcast("player_#{user.id}", method: 'remove_target')
    end
  end
  
  # Give bounty to player
  def give_bounty(player)
    
    value = rand(5..15)
    
    value = value * 3 if self.location.system.security_status == 'low' || self.location.location_type == 'exploration_site' || self.politician?
    
    value = value * 50 if self.wanted_enemy?
    
    player.give_units(value)
    
    # Also give reputation
    corporation = player.system.locations.where(location_type: :station).first&.faction.id rescue nil
    if corporation
      ActionCable.server.broadcast("player_#{player.id}", method: 'notify_alert', text: I18n.t('notification.gained_reputation', user: self.name, amount: 0.01))
      case corporation
        when 1
          player.update_columns(reputation_1: player.reputation_1 + 0.01)
        when 2
          player.update_columns(reputation_2: player.reputation_2 + 0.01)
        when 3
          player.update_columns(reputation_3: player.reputation_3 + 0.01)
      end
    end
    
    ActionCable.server.broadcast("player_#{player.id}", method: 'notify_alert', text: I18n.t('notification.received_bounty', user: self.name, amount: value))
    ActionCable.server.broadcast("player_#{player.id}", method: 'refresh_player_info')
  end
end
