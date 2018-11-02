class Asteroid < ApplicationRecord
  belongs_to :location
  
  enum asteroid_type: [:gold, :bronze, :copper]
end
