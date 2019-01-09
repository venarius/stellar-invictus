class Location < ApplicationRecord
  belongs_to :system
  belongs_to :faction, optional: true
  belongs_to :mission, optional: true
  
  has_many :users
  has_many :asteroids, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :npcs, dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :spaceships
  has_many :market_listings, dependent: :destroy
  has_many :missions, dependent: :destroy
  
  has_one :chat_room, dependent: :destroy
  
  enum location_type: [:station, :asteroid_field, :jumpgate, :mission, :exploration_site]
  enum station_type: [:industrial_station, :warfare_plant, :mining_station, :research_station]
  
  delegate :security_status, :name, :to => :system, :prefix => true
  delegate :difficulty, :enemy_amount, :to => :mission, :prefix => true
  delegate :name, :to => :faction, :prefix => true
  
  before_destroy do
    location = Location.where.not(id: self.id).first
    self.users.update_all(location_id: location.id, system_id: location.system.id)
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
  
  def get_name
    if I18n.t("locations.#{self.location_type}") != ""
      "#{I18n.t("locations.#{self.location_type}")} #{self.name}"
    else
      if self.station?
        I18n.t("locations.#{self.station_type}")
      else
        self.name
      end
    end
  end
  
end
