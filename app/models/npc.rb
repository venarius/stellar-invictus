class Npc < ApplicationRecord
  belongs_to :location, optional: true
  
  enum npc_type: [:enemy, :police]
  
  def die
    NpcDiedWorker.perform_async(self.id)
  end
end
