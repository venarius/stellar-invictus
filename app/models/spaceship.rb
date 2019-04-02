class Spaceship < ApplicationRecord
  include HasLookupAttributes

  ## -- RELATIONSHIPS
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  has_many :items, dependent: :destroy

  @lookup_data = YAML.load_file("#{Rails.root.to_s}/config/variables/spaceships.yml")
  @default_base = :name

  ## — CLASS METHODS
  def self.ship_variables
    @lookup_data
  end

  ## — INSTANCE METHODS

  # Get Weight of all Items in Ship
  def get_weight
    Item.where(spaceship: self, equipped: false).map(&:total_weight).sum
  end

  # Get free weight
  def get_free_weight
    self.get_storage_capacity - self.get_weight
  end

  # Get Items in ship storage
  def get_items(equipped_switch = false)
    query = self.items
    query = query.where(equipped: false) if equipped_switch
    query
  end

  # Get all Equipment in Ship
  def get_equipment
    self.items.where("loader LIKE ?", "equipment%")
  end

  # Get all unequipped Equipment in Ship
  def get_unequipped_equipment
    get_equipment.where(equipped: false)
  end

  # Get equipped Equipment in Ship
  def get_equipped_equipment
    get_equipment.where(equipped: true)
  end

  def get_equipped_equipment_of_slot_type(type)
    type = type.to_s
    self.get_equipped_equipment.each_with_object([]) do |item, result|
      result << item if item.get_attribute(:slot_type) == type
    end
  end

  def get_equipped_equipment_of_type(type)
    type = type.to_s
    self.get_equipped_equipment.each_with_object([]) do |item, result|
      result << item if item.get_attribute(:type) == type
    end
  end

  # Get Main Equipment in Ship
  def get_main_equipment(active = false)
    items = get_equipped_equipment_of_slot_type(:main)
    items = items.select(&:active) if active
    items
  end

  # Get Utility Equipment in Ship
  def get_utility_equipment
    get_equipped_equipment_of_slot_type(:utility)
  end

  # Deactivate Equipment
  def deactivate_equipment
    self.get_equipped_equipment.each do |item|
      item.update(active: false)
    end
  end

  # Deactivate Weapons
  def deactivate_weapons
    self.get_equipped_equipment_of_type('Weapon').each do |item|
      item.update(active: false)
    end
  end

  # Deactivate Selfrepair Equipment
  def deactivate_selfrepair_equipment
    self.get_equipped_equipment_of_type('Repair Bot').each do |item|
      item.update_columns(active: false)
    end
  end

  # Deactivate Remoterepair Equipment
  def deactivate_remoterepair_equipment
    self.get_equipped_equipment_of_type('Repair Beam').each do |item|
      item.update_columns(active: false)
    end
  end

  # Drop Loot
  def drop_loot
    if self.items.present?
      structure = Structure.create(location: self.user.location, structure_type: :wreck)
      hash = []
      self.items.each do |item|
        if rand(0..1) == 1
          hash << { name: item.get_attribute('name'), dropped: true, amount: item.count, equipped: item.equipped }
          item.update_columns(structure_id: structure.id, spaceship_id: nil, equipped: false, count: item.count)
        else
          hash << { name: item.get_attribute('name'), dropped: false, amount: item.count, equipped: item.equipped }
        end
      end
      hash
    end
  end

  # Get Storage Capacity of Ship
  def get_storage_capacity
    storage = self.get_attribute('storage')
    storage = storage + (self.get_attribute("upgrade.storage_amplifier", default: 1)**self.level).round if (self.level > 0)
    stack = 0
    self.get_utility_equipment.each do |item|
      if (item.get_attribute('type') == "Storage") && item.equipped
        item_attr = item.get_attribute('storage_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end

      item_attr = item_attr * self.get_attribute("trait.storage_amplifier", default: 1) if item_attr
      item_attr = 0 unless item_attr
      storage = storage + storage * (item_attr / 100)
    end
    storage = storage * self.user.faction.get_attribute('storage_amplifier', default: 1)
    storage.round
  end

  # Get Power of Ship
  def get_power
    power = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('damage') if (item.get_attribute('type') == "Weapon") && item.equipped && item.active
      item_attr = item_attr * self.get_attribute("trait.damage_amplifier", default: 1) if item_attr
      item_attr = 0 unless item_attr
      power = power + item_attr
    end
    power = power * self.user.faction.get_attribute('damage_amplifier')
    power.round
  end

  # Get Selfrepair Amount of Ship
  def get_selfrepair
    repair = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('repair_amount') if (item.get_attribute('type') == "Repair Bot") && item.equipped && item.active
      item_attr = item_attr * self.get_attribute("trait.repair_amount_amplifier", default: 1) if item_attr
      item_attr = 0 unless item_attr
      repair = repair + item_attr
    end
    repair
  end

  # Get Remoterepair Amount of Ship
  def get_remoterepair
    repair = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('repair_amount') if (item.get_attribute('type') == "Repair Beam") && item.equipped && item.active
      item_attr = item_attr * self.get_attribute("trait.remote_repair_amplifier", default: 1) if item_attr
      item_attr = 0 unless item_attr
      repair = repair + item_attr
    end
    repair.round
  end

  # Get Defense of ship
  def get_defense
    defense = self.get_attribute('defense')
    defense = defense + (self.get_attribute("upgrade.defense_amplifier", default: 1)**self.level).round if self.level > 0
    stack = 0
    self.get_utility_equipment.each do |item|
      if (item.get_attribute('type') == "Defense") && item.equipped
        item_attr = item.get_attribute('defense_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end

      item_attr = item_attr * self.get_attribute("trait.defense_amplifier", default: 1) if item_attr
      item_attr = 0 unless item_attr
      defense = defense + defense * (item_attr / 100)
    end
    defense = defense * self.user.faction.get_attribute('defense_amplifier', default: 1)
    # cap to 70 max
    defense = 70 if defense > 70
    defense.round
  end

  # Get Mining Amount of ship
  def get_mining_amount
    mining_amount = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('mining_amount') if (item.get_attribute('type') == "Mining Laser") && item.equipped
      item_attr = item_attr * self.get_attribute("trait.mining_amount_amplifier", default: 1) if item_attr
      item_attr = 0 unless item_attr
      mining_amount = mining_amount + item_attr
    end
    mining_amount.round
  end

  # Get free main slots
  def get_free_main_slots
    self.get_attribute('main_equipment_slots') - get_main_equipment.select(&:equipped).size
  end

  # Get free utility slots
  def get_free_utility_slots
    self.get_attribute('utility_equipment_slots') - get_utility_equipment.select(&:equipped).size
  end

  # Get align time
  def get_align_time
    align_time = self.get_attribute('align_time')
    align_time = align_time - (self.get_attribute("upgrade.align_amplifier")**self.level).round if self.get_attribute("upgrade.align_amplifier") && (self.level > 0)
    stack = 0
    self.get_equipment.each do |item|
      if (item.get_attribute('type') == "Hull") && item.equipped
        item_attr = item.get_attribute('align_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end

      item_attr = item_attr * self.get_attribute("trait.align_amplifier") if (self.get_attribute("trait.align_amplifier") rescue nil) && item_attr
      item_attr = 0 unless item_attr
      align_time = align_time - align_time * (item_attr / 100)
    end
    align_time.round
  end

  # Get target time
  def get_target_time
    target_time = self.get_attribute('target_time')
    target_time = target_time - (self.get_attribute("upgrade.target_amplifier")**self.level).round if self.get_attribute("upgrade.target_amplifier") && (self.level > 0)
    stack = 0
    self.get_equipment.each do |item|
      if (item.get_attribute('type') == "Sensor") && item.equipped
        item_attr = item.get_attribute('target_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end

      item_attr = item_attr * self.get_attribute("trait.target_amplifier") if (self.get_attribute("trait.target_amplifier") rescue nil) && item_attr
      item_attr = 0 unless item_attr
      target_time = target_time - target_time * (item_attr / 100)
    end
    target_time.round
  end

  # If is warp disrupted
  def is_warp_disrupted
    weight = 0
    User.where(target_id: self.user.id, is_attacking: true).where.not(online: 0).each do |user|
      if user.active_spaceship.has_active_warp_disruptor
        user.active_spaceship.get_main_equipment(true).each do |item|
          item_attr = item.get_attribute('disrupt_strength') if (item.get_attribute('type') == "Warp Disruptor") && item.active && item.equipped
          item_attr = item_attr * self.get_attribute("trait.warp_disrupt_amplifier") if (self.get_attribute("trait.warp_disrupt_amplifier") rescue nil) && item_attr
          item_attr = 0 unless item_attr
          weight = weight + (item_attr.round rescue 0)
        end
      end
    end
    self.get_utility_equipment.each do |item|
      weight = weight - item.get_attribute('disrupt_immunity') if (item.get_attribute('type') == "Warp Core Stabilizer") && item.equipped
      weight = weight - self.get_attribute("trait.disrupt_immunity") if (self.get_attribute("trait.disrupt_immunity") rescue nil)
    end
    weight > 0 ? true : false
  end

  # Has active warp disruptor
  def has_active_warp_disruptor
    self.get_main_equipment(true).each do |item|
      return true if item.get_attribute('type') == "Warp Disruptor"
    end
    false
  end

  # Get value in credits of ship and its items
  def get_total_value
    # Add ship
    value = self.get_attribute(:price, default: 0)

    # Add for items / equipment
    value += self.get_items.map(&:total_price).sum

    value
  end

  # Get Scanner of Ship
  def get_scanner_range
    attribute = 0
    self.get_main_equipment.each do |item|
      attribute = attribute + item.get_attribute('scanner_range') if item.get_attribute('type') == "Scanner"
    end
    attribute = attribute + self.get_attribute("trait.scanner_range") if (self.get_attribute("trait.scanner_range") rescue nil)
    return attribute
  end

  # Get HP Color Value
  def get_hp_color
    percentage = self.hp / (get_attribute(:hp) / 100.0)
    case percentage
    when 0..29
      'color-red'
    when 30..74
      'color-sec-medium'
    when 75..100
      'color-highgreen'
    end
  end

  # Check if has directional_scanner
  def get_directional_scanner
    return true if (self.get_attribute("trait.directional_scanner") rescue false)
    self.get_main_equipment().each do |item|
      return true if item.get_attribute('type') == 'Directional Scanner'
    end
    false
  end

  # Check if has jump drive
  def get_jump_drive
    return true if (self.get_attribute("trait.jump_drive") rescue false)
    false
  end

  # Get max HP
  def get_max_hp
    hp = get_attribute(:hp)
    hp += (self.get_attribute("upgrade.hp_amplifier", default: 0)**self.level).round if (self.level > 0)
    hp
  end

  # Repair
  def repair
    self.update(hp: self.get_max_hp)
  end

end
