class Npc < ApplicationRecord
  belongs_to :location, optional: true
  
  enum npc_type: [:enemy, :police]
  
  def die
    NpcDiedWorker.perform_async(self.id)
  end
  
  def drop_loot
    loader = ["asteroid.iron", "asteroid.nickel", "asteroid.cobalt"]
    structure = Structure.create(location: self.location, structure_type: 'wreck')
    rand(1..5).times do
      Item.create(loader: loader.sample, structure: structure)
    end
  end
end
