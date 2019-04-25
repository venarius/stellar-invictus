# == Schema Information
#
# Table name: items
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(FALSE)
#  count        :integer          default(1)
#  equipped     :boolean          default(FALSE)
#  loader       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :bigint(8)
#  mission_id   :bigint(8)
#  spaceship_id :bigint(8)
#  structure_id :integer
#  user_id      :bigint(8)
#
# Indexes
#
#  index_items_on_loader        (loader)
#  index_items_on_location_id   (location_id)
#  index_items_on_mission_id    (mission_id)
#  index_items_on_spaceship_id  (spaceship_id)
#  index_items_on_structure_id  (structure_id)
#  index_items_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (spaceship_id => spaceships.id)
#  fk_rails_...  (user_id => users.id)
#

class Item < ApplicationRecord
  include HasLookupAttributes
  @lookup_data = YAML.load_file("#{Rails.root}/config/variables/items.yml")
  @default_base = :loader

  ensure_by :id, :loader

  ## -- RELATIONSHIPS
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  belongs_to :spaceship, optional: true
  belongs_to :structure, optional: true
  belongs_to :mission, optional: true

  ## -- CONSTANTS
  STACK_PENALTIES = [1.0, 0.87, 0.57, 0.28, 0.10, 0.03, 0.0, 0.0, 0.0].freeze

  EQUIPMENT_XTRA = %w[
    equipment.directional_scanners.directional_scanner
    equipment.scanner.deepspace_scanner
  ].freeze

  EQUIPMENT_EASY = %w[
    equipment.defense.ion_shield
    equipment.hulls.light_hull
    equipment.miner.basic_miner
    equipment.remote_repair.simple_repair_beam
    equipment.repair_bots.simple_repair_bot
    equipment.scanner.basic_scanner
    equipment.sensors.small_sensor
    equipment.storage.small_black_hole
    equipment.warp_core_stabilizers.basic_warp_core_stabilizer
    equipment.warp_disruptors.basic_warp_disruptor
    equipment.weapons.laser_gatling
  ].freeze

  EQUIPMENT_MEDIUM = %w[
    equipment.miner.advanced_miner
    equipment.remote_repair.advanced_repair_beam
    equipment.repair_bots.advanced_repair_bot
    equipment.scanner.advanced_scanner
    equipment.storage.medium_black_hole
    equipment.warp_core_stabilizers.try_pyon_warp_core_stabilizer
    equipment.warp_disruptors.try_pyon_warp_disruptor
    equipment.weapons.try_pyon_laser
  ].freeze

  # Equipment Hard
  EQUIPMENT_HARD = %w[
    equipment.defense.try_pyon_shield
    equipment.hulls.ultralight_hull
    equipment.miner.core_miner
    equipment.remote_repair.colton_repair_beam
    equipment.repair_bots.colton_repair_bot
    equipment.scanner.military_scanner
    equipment.sensors.try_pyon_sensor
    equipment.storage.large_black_hole
    equipment.warp_core_stabilizers.military_warp_core_stabilizer
    equipment.warp_disruptors.military_warp_disruptor
    equipment.weapons.military_laser
  ].freeze

  EQUIPMENT = EQUIPMENT_EASY + EQUIPMENT_MEDIUM + EQUIPMENT_HARD + EQUIPMENT_XTRA

  MATERIALS = %w[
    materials.ai_components
    materials.antimatter
    materials.fusion_electronics
    materials.laser_diodes
    materials.metal_plates
    materials.sensor_electronics
  ].freeze

  ASTEROIDS = %w[
    asteroid.cobalt_ore
    asteroid.iron_ore
    asteroid.lunarium_ore
    asteroid.nickel_ore
    asteroid.septarium_ore
    asteroid.titanium_ore
    asteroid.tryon_ore
  ].freeze

  DELIVERY = %w[
    delivery.data
    delivery.intelligence
  ].freeze

  ITEMS = EQUIPMENT + MATERIALS + ASTEROIDS

  ## — INSTANCE METHODS
  def total_price
    self.get_attribute(:price, default: 0) * self.count
  end

  def total_weight
    self.get_attribute(:weight, default: 0) * self.count
  end
end
