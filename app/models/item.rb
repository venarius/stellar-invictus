class Item < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  belongs_to :spaceship, optional: true
  belongs_to :structure, optional: true

  @item_variables = YAML.load_file("#{Rails.root.to_s}/config/variables/items.yml")

  def get_attribute(attribute)
    atty = self.loader.split(".")
    out = Item.item_variables[atty[0]]
    self.loader.count('.').times do |i|
      out = out[atty[i + 1]]
    end
    out[attribute]
  end

  def self.remove_from_user(attr)
    user = attr[:user]
    if attr[:location]
      item = Item.find_by(user: user, location: attr[:location], loader: attr[:loader], equipped: false) rescue nil
    else
      item = Item.find_by(spaceship: user.active_spaceship, loader: attr[:loader], equipped: false) rescue nil
    end

    if item
      item.update_columns(count: item.count - attr[:amount])
      item.destroy if item.reload.count <= 0
    end
  end

  def self.give_to_user(attr)
    user = attr[:user]
    if attr[:location]
      item = Item.find_by(user: user, location: attr[:location], loader: attr[:loader], equipped: false) rescue nil
      item ? item.update_columns(count: item.count + attr[:amount]) : Item.create(user: user, location: attr[:location], loader: attr[:loader], count: attr[:amount], equipped: false)
    else
      item = Item.find_by(spaceship: user.active_spaceship, loader: attr[:loader], equipped: false) rescue nil
      item ? item.update_columns(count: item.count + attr[:amount]) : Item.create(spaceship: user.active_spaceship, loader: attr[:loader], count: attr[:amount], equipped: false)
    end
  end

  def self.store_in_station(attr)
    user = attr[:user]
    item = Item.find_by(spaceship: user.active_spaceship, loader: attr[:loader], equipped: false) rescue nil
    if item
      if item.count > attr[:amount]
        item.update_columns(count: item.count - attr[:amount])
        Item.give_to_user(user: user, loader: attr[:loader], location: user.location, amount: attr[:amount])
      else
        station_item = Item.find_by(user: user, location: user.location, loader: item.loader, equipped: false) rescue nil
        station_item ? (station_item.update_columns(count: station_item.count + item.count) && item.destroy) : item.update_columns(user_id: user.id, location_id: user.location.id, spaceship_id: nil, equipped: false, active: false)
      end
    end
  end

  def self.store_in_ship(attr)
    user = attr[:user]
    item = Item.find_by(user: user, location: user.location, loader: attr[:loader], equipped: false) rescue nil
    if item
      if item.count > attr[:amount]
        item.update_columns(count: item.count - attr[:amount])
        Item.give_to_user(user: user, loader: attr[:loader], amount: attr[:amount])
      else
        ship_item = Item.find_by(spaceship: user.active_spaceship, loader: item.loader, equipped: false) rescue nil
        ship_item ? (ship_item.update_columns(count: ship_item.count + item.count) && item.destroy) : item.update_columns(user_id: nil, location_id: nil, spaceship_id: user.active_spaceship.id, equipped: false, active: false)
      end
    end
  end

  # Item Variables
  def self.item_variables
    @item_variables
  end

  # Stack Penalties
  def self.stack_penalties
    [1.0, 0.87, 0.57, 0.28, 0.10, 0.03, 0.0, 0.0, 0.0]
  end

  # Equipment
  def self.equipment
    ["equipment.weapons.laser_gatling", "equipment.weapons.try_pyon_laser", "equipment.weapons.military_laser",
     "equipment.hulls.light_hull", "equipment.hulls.ultralight_hull",
     "equipment.sensors.small_sensor", "equipment.sensors.try_pyon_sensor",
     "equipment.scanner.basic_scanner", "equipment.scanner.advanced_scanner", "equipment.scanner.military_scanner", "equipment.scanner.deepspace_scanner",
     "equipment.directional_scanners.directional_scanner",
     "equipment.warp_disruptors.basic_warp_disruptor", "equipment.warp_disruptors.try_pyon_warp_disruptor", "equipment.warp_disruptors.military_warp_disruptor",
     "equipment.warp_core_stabilizers.basic_warp_core_stabilizer", "equipment.warp_core_stabilizers.try_pyon_warp_core_stabilizer", "equipment.warp_core_stabilizers.military_warp_core_stabilizer",
     "equipment.miner.basic_miner", "equipment.miner.advanced_miner", "equipment.miner.core_miner",
     "equipment.repair_bots.simple_repair_bot", "equipment.repair_bots.advanced_repair_bot", "equipment.repair_bots.colton_repair_bot",
     "equipment.remote_repair.simple_repair_beam", "equipment.remote_repair.advanced_repair_beam", "equipment.remote_repair.colton_repair_beam",
     "equipment.defense.ion_shield", "equipment.defense.try_pyon_shield",
     "equipment.storage.small_black_hole", "equipment.storage.medium_black_hole", "equipment.storage.large_black_hole"]
  end

  # Equipment Easy
  def self.equipment_easy
    ["equipment.weapons.laser_gatling",
     "equipment.hulls.light_hull",
     "equipment.sensors.small_sensor",
     "equipment.scanner.basic_scanner",
     "equipment.warp_disruptors.basic_warp_disruptor",
     "equipment.warp_core_stabilizers.basic_warp_core_stabilizer",
     "equipment.miner.basic_miner",
     "equipment.repair_bots.simple_repair_bot",
     "equipment.remote_repair.simple_repair_beam",
     "equipment.defense.ion_shield",
     "equipment.storage.small_black_hole"]
  end

  # Equipment Medium
  def self.equipment_medium
    ["equipment.weapons.try_pyon_laser",
     "equipment.scanner.advanced_scanner",
     "equipment.warp_disruptors.try_pyon_warp_disruptor",
     "equipment.warp_core_stabilizers.try_pyon_warp_core_stabilizer",
     "equipment.miner.advanced_miner",
     "equipment.repair_bots.advanced_repair_bot",
     "equipment.remote_repair.advanced_repair_beam",
     "equipment.storage.medium_black_hole"]
  end

  # Equipment Hard
  def self.equipment_hard
    ["equipment.weapons.military_laser",
     "equipment.hulls.ultralight_hull",
     "equipment.sensors.try_pyon_sensor",
     "equipment.scanner.military_scanner",
     "equipment.warp_disruptors.military_warp_disruptor",
     "equipment.warp_core_stabilizers.military_warp_core_stabilizer",
     "equipment.miner.core_miner",
     "equipment.repair_bots.colton_repair_bot",
     "equipment.remote_repair.colton_repair_beam",
     "equipment.defense.try_pyon_shield",
     "equipment.storage.large_black_hole"]
  end

  # Materials
  def self.materials
    ["materials.sensor_electronics", "materials.antimatter", "materials.fusion_electronics",
     "materials.ai_components", "materials.metal_plates", "materials.laser_diodes"]
  end

  # Asteroids
  def self.asteroids
    ["asteroid.nickel_ore", "asteroid.septarium_ore", "asteroid.cobalt_ore", "asteroid.iron_ore", "asteroid.titanium_ore", "asteroid.tryon_ore", "asteroid.lunarium_ore"]
  end

  # Items
  def self.items
    self.equipment + self.materials + self.asteroids
  end

  # Delivery
  def self.delivery
    ["delivery.data", "delivery.intelligence"]
  end
end
