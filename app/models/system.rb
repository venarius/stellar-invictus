class System < ApplicationRecord
  has_many :users
  has_many :locations, dependent: :destroy
  has_many :chat_rooms, dependent: :destroy
  
  enum security_status: [:high, :medium, :low, :wormhole]
  
  after_create do
    ChatRoom.create(chatroom_type: 'local', title: self.name, system: self)
  end
  
  # Updates local players of every user in system
  def update_local_players
    users = User.where("online > 0").where(system: self)
    self.locations.each do |location|
      ActionCable.server.broadcast("location_#{location.id}", method: 'update_players_in_system', 
        count: users.count, names: ApplicationController.helpers.map_and_sort(users)) if location.users.count > 0
    end
  end
  
  # Get owning Faction
  def get_faction
    self.locations.where(location_type: 'station').first.faction rescue nil
  end
  
  # Mapdata
  def self.mapdata
    YAML.load_file("#{Rails.root.to_s}/config/variables/mapdata.yml")
  end
  
  # Pathfinder
  def self.pathfinder
    YAML.load_file("#{Rails.root.to_s}/config/variables/pathfinder.yml")
  end
end
