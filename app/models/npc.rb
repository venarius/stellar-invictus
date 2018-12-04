class Npc < ApplicationRecord
  belongs_to :location, optional: true
  
  enum npc_type: [:enemy, :police]
  
  # Lets the npc die
  def die
    NpcDiedWorker.perform_async(self.id)
  end
  
  # Lets the npc drop loot
  def drop_loot
    loader = ["asteroid.iron", "asteroid.nickel", "asteroid.cobalt"] + MATERIALS
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
end
