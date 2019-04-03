# == Schema Information
#
# Table name: locations
#
#  id            :bigint(8)        not null, primary key
#  enemy_amount  :integer          default(0)
#  hidden        :boolean          default(FALSE)
#  location_type :integer
#  name          :string
#  player_market :boolean          default(FALSE)
#  station_type  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  faction_id    :bigint(8)
#  mission_id    :bigint(8)
#  system_id     :bigint(8)
#
# Indexes
#
#  index_locations_on_faction_id  (faction_id)
#  index_locations_on_mission_id  (mission_id)
#  index_locations_on_system_id   (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (system_id => systems.id)
#

class Location < ApplicationRecord
  belongs_to :system
  belongs_to :faction, optional: true
  belongs_to :mission, optional: true

  has_many :users
  has_many :asteroids,  dependent: :destroy
  has_many :items,      dependent: :destroy
  has_many :npcs,       dependent: :destroy
  has_many :structures, dependent: :destroy
  has_many :spaceships
  has_many :market_listings, dependent: :destroy
  has_many :missions, dependent: :destroy

  has_one :chat_room, dependent: :destroy

  enum location_type: %i[station asteroid_field jumpgate mission exploration_site wormhole]
  enum station_type:  %i[industrial_station warfare_plant mining_station research_station trillium_casino]

  # NOTE: This don't help readability, in fact, they make it more difficult to
  # follow the chain of methods in other objects
  # delegate :security_status, :name, to: :system, prefix: true
  # delegate :difficulty, :enemy_amount, to: :mission, prefix: true
  # delegate :name, to: :faction, prefix: true

  before_destroy do
    location = Location.where.not(id: self.id).first
    self.users.update_all(location_id: location.id, system_id: location.system.id)
  end

  def channel_id
    "location_#{self.id}"
  end

  def jumpgate
    Jumpgate.where("origin_id = ? OR destination_id = ?", self.id, self.id).first
  end

  def get_items(id)
    Item.where(user: User.find(id), location: self)
  end

  def get_name
    if I18n.t("locations.#{self.location_type}") != ""
      "#{I18n.t("locations.#{self.location_type}")} #{self.name}"
    else
      if self.station? && !self.name
        I18n.t("locations.#{self.station_type}")
      else
        self.name
      end
    end
  end

end
