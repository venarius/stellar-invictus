class Location < ApplicationRecord
  belongs_to :system
  belongs_to :faction, optional: true
  belongs_to :mission, optional: true
  
  has_many :users, dependent: :destroy
  has_many :asteroids, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :npcs, dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :spaceships, dependent: :destroy
  has_many :market_listings, dependent: :destroy
  has_many :missions, dependent: :destroy
  
  has_one :chat_room, dependent: :destroy
  
  enum location_type: [:station, :asteroid_field, :jumpgate, :mission, :exploration_site]
  
  enum exploration_type: [:combat, :abandoned_structure, :asteroid_field]
  
  after_create do
    ChatRoom.create(chatroom_type: 'local', title: self.name, location: self)
  end
  
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
  
  def is_factory
    self.location_type == 'station' and self.name.include? "Factory"  
  end
  
end
