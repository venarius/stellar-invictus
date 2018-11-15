class Asteroid < ApplicationRecord
  belongs_to :location
  
  enum asteroid_type: [:nickel, :iron, :cobalt]
end
