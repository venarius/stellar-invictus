class Npc < ApplicationRecord
  belongs_to :location, optional: true
  
  enum npc_type: [:enemy, :police]
end
