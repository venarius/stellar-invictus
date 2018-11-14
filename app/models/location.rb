class Location < ApplicationRecord
  belongs_to :system
  has_many :users
  belongs_to :faction, optional: true
  has_many :asteroids
  has_many :items
  has_many :npcs
  
  enum location_type: [:station, :asteroid_field, :jumpgate]
  
  def jumpgate
    Jumpgate.where("origin_id = ? OR destination_id = ?", self.id, self.id).first
  end
  
  def get_items(id)
    items = Item.where(user: User.find(id), location: self)
    storage = Hash.new(0)
    items.each do |value|
      storage[value.loader] += 1
    end
    storage
  end
  
  def get_ships_for_sale
    val = {}
    ship_names = STATION_VARIABLES[self.id]['spaceships']
    ship_names.each do |name|
      val[name] = (SHIP_VARIABLES[name])
    end
    val
  end
  
end
