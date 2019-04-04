# == Schema Information
#
# Table name: systems
#
#  id              :bigint(8)        not null, primary key
#  name            :string
#  security_status :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class System < ApplicationRecord
  ensure_by :id, :name

  has_many :locations, dependent: :destroy
  has_many :users, through: :locations
  has_many :chat_rooms, dependent: :destroy

  enum security_status: [:high, :medium, :low, :wormhole]

  after_create do
    ChatRoom.create(chatroom_type: :local, title: self.name, system: self)
  end

  # Updates local players of every user in system
  def update_local_players
    user_query = self.users.is_online
    user_count = user_query.count
    user_names = ApplicationController.helpers.map_and_sort(user_query)
    location_ids = user_query.select(:location_id).distinct.pluck(:location_id)

    self.locations.where(id: location_ids).each do |location|
      location.broadcast( :update_players_in_system, count: user_count, names: user_names)
    end
  end

  # Get owning Faction
  def get_faction
    self.locations.station.first&.faction
  end

  # Mapdata
  def self.mapdata
    @mapdata ||= YAML.load_file("#{Rails.root}/config/variables/mapdata.yml")
  end

  # Pathfinder
  def self.pathfinder
    @pathfinder ||= YAML.load_file("#{Rails.root}/config/variables/pathfinder.yml")
  end
end
