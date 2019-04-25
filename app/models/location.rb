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
#  index_locations_on_faction_id     (faction_id)
#  index_locations_on_location_type  (location_type)
#  index_locations_on_mission_id     (mission_id)
#  index_locations_on_name           (name)
#  index_locations_on_station_type   (station_type)
#  index_locations_on_system_id      (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (system_id => systems.id)
#

class Location < ApplicationRecord
  include CanBroadcast

  ## -- RELATIONSHIPS
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

  ## -- ATTRIBUTES
  enum location_type: %i[station asteroid_field jumpgate mission exploration_site wormhole]
  enum station_type:  %i[industrial_station warfare_plant mining_station research_station trillium_casino]

  ## -- SCOPES
  scope :is_hidden, -> { where(hidden: true) }
  scope :not_hidden, -> { where(hidden: [false, nil]) }

  ## -- CALLBACKS
  before_destroy :move_users_in_this_location_to_the_first_location

  ## — INSTANCE METHODS
  def channel_id
    "location_#{self.id}"
  end

  def jumpgate
    Jumpgate.where('origin_id = ? OR destination_id = ?', self.id, self.id).first
  end

  def get_items(id)
    Item.where(user_id: id, location: self)
  end

  def get_name
    if I18n.t("locations.#{self.location_type}") != ''
      "#{I18n.t("locations.#{self.location_type}")} #{self.name}"
    else
      if self.station? && !self.name
        I18n.t("locations.#{self.station_type}")
      else
        self.name
      end
    end
  end

  def full_name
    "#{get_name} #{self.system.name}"
  end

  def random_online_in_space_user
    self.users.in_space.is_online.random_row
  end

  def scan_visible?(user)
    # Logic from _locations_table.html.erb
    return false if self == user.location
    return false if self.wormhole? && user.active_spaceship&.get_scanner_range.to_i < 10
    if self.mission
      return true if self.mission.active? && self.mission.user_id == user.ids
      return true if self.mission.user&.in_same_fleet_as(user)
      return false
    end
    true
  end

  private

  def move_users_in_this_location_to_the_first_location
    location = Location.where.not(id: self.id).first
    self.users.update_all(location_id: location.id, system_id: location.system.id)
  end
end
