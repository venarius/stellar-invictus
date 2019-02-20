class Spaceship < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  has_many :items, dependent: :destroy
  
  # Get Weight of all Items in Ship
  def get_weight
    weight = 0
    Item.where(spaceship: self, equipped: false).each do |item|
      weight = weight + item.get_attribute('weight') * item.count
    end
    weight
  end
  
  # Get free weight
  def get_free_weight
    self.get_storage_capacity - self.get_weight
  end
  
  # Get Attribute of ship
  def get_attribute(attribute=nil)
    Spaceship.ship_variables[self.name][attribute] rescue nil
  end
  
  # Get Items in ship storage
  def get_items(equipped_switch=false)
    equipped_switch ? Item.where(spaceship: self, equipped: false) : Item.where(spaceship: self)
  end
  
  # Get all Equipment in Ship
  def get_equipment
    Item.where(spaceship: self).where("loader LIKE ?", "equipment%")
  end
  
  # Get all unequipped Equipment in Ship
  def get_unequipped_equipment
    Item.where(spaceship: self, equipped: false).where("loader LIKE ?", "equipment%")
  end
  
  # Get equipped Equipment in Ship
  def get_equipped_equipment
    Item.where(spaceship: self, equipped: true).where("loader LIKE ?", "equipment%")
  end
  
  # Get Main Equipment in Ship
  def get_main_equipment(active=false)
    items = []
    self.get_equipped_equipment.each do |item|
      active ? (items << item if item.get_attribute('slot_type') == "main" and item.active) : (items << item if item.get_attribute('slot_type') == "main")
    end
    items
  end
  
  # Get Utility Equipment in Ship
  def get_utility_equipment
    items = []
    self.get_equipped_equipment.each do |item|
      items << item if item.get_attribute('slot_type') == "utility"
    end
    items
  end
  
  # Deactivate Equipment
  def deactivate_equipment
    self.get_equipped_equipment.each do |item|
      item.update_columns(active: false) if item.active
    end
  end
  
  # Deactivate Weapons
  def deactivate_weapons
    self.get_equipped_equipment.each do |item|
      item.update_columns(active: false) if item.active and item.get_attribute('type') == "Weapon"
    end
  end
  
  # Deactivate Selfrepair Equipment
  def deactivate_selfrepair_equipment
    self.get_equipped_equipment.each do |item|
      item.update_columns(active: false) if item.active and item.get_attribute('type') == "Repair Bot"
    end
  end
  
  # Deactivate Remoterepair Equipment
  def deactivate_remoterepair_equipment
    self.get_equipped_equipment.each do |item|
      item.update_columns(active: false) if item.active and item.get_attribute('type') == "Repair Beam"
    end
  end
  
  # Drop Loot
  def drop_loot
    items = self.get_items
    if items.present?
      structure = Structure.create(location: self.user.location, structure_type: 'wreck')
      hash = []
      items.each do |item|
        if rand(0..1) == 1
          hash << {name: item.get_attribute('name'), dropped: true, amount: item.count, equipped: item.equipped}
          item.update_columns(structure_id: structure.id, spaceship_id: nil, equipped: false, count: item.count)
        else
          hash << {name: item.get_attribute('name'), dropped: false, amount: item.count, equipped: item.equipped}
        end
      end
      hash
    end
  end
  
  # Get Storage Capacity of Ship
  def get_storage_capacity
    storage = self.get_attribute('storage')
    storage = storage + (Spaceship.ship_variables[name]['upgrade']['storage_amplifier'] ** self.level).round if Spaceship.ship_variables[name]['upgrade']['storage_amplifier'] and self.level > 0
    stack = 0
    self.get_utility_equipment.each do |item|
      if item.get_attribute('type') == "Storage" and item.equipped
        item_attr = item.get_attribute('storage_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end
      
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['storage_amplifier'] if (Spaceship.ship_variables[name]['trait']['storage_amplifier'] rescue nil) and item_attr
      item_attr = 0 unless item_attr
      storage = storage + storage * (item_attr / 100)
    end
    storage = storage * self.user.faction.get_attribute('storage_amplifier')
    storage.round
  end
  
  # Get Power of Ship
  def get_power
    power = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('damage') if item.get_attribute('type') == "Weapon" and item.equipped and item.active
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['damage_amplifier'] if (Spaceship.ship_variables[name]['trait']['damage_amplifier'] rescue nil) and item_attr
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
      item_attr = item.get_attribute('repair_amount') if item.get_attribute('type') == "Repair Bot" and item.equipped and item.active
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['repair_amount_amplifier'] if (Spaceship.ship_variables[name]['trait']['repair_amount_amplifier'] rescue nil) and item_attr
      item_attr = 0 unless item_attr
      repair = repair + item_attr
    end
    repair
  end
  
  # Get Remoterepair Amount of Ship
  def get_remoterepair
    repair = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('repair_amount') if item.get_attribute('type') == "Repair Beam" and item.equipped and item.active
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['remote_repair_amplifier'] if (Spaceship.ship_variables[name]['trait']['remote_repair_amplifier'] rescue nil) and item_attr
      item_attr = 0 unless item_attr
      repair = repair + item_attr
    end
    repair.round
  end
  
  # Get Defense of ship
  def get_defense
    defense = self.get_attribute('defense')
    defense = defense + (Spaceship.ship_variables[name]['upgrade']['defense_amplifier'] ** self.level).round if Spaceship.ship_variables[name]['upgrade']['defense_amplifier'] and self.level > 0
    stack = 0
    self.get_utility_equipment.each do |item|
      if item.get_attribute('type') == "Defense" and item.equipped
        item_attr = item.get_attribute('defense_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end
      
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['defense_amplifier'] if (Spaceship.ship_variables[name]['trait']['defense_amplifier'] rescue nil) and item_attr
      item_attr = 0 unless item_attr
      defense = defense + defense * (item_attr / 100)
    end
    defense = defense * self.user.faction.get_attribute('defense_amplifier')
    # cap to 70 max
    defense = 70 if defense > 70
    defense.round
  end
  
  # Get Mining Amount of ship
  def get_mining_amount
    mining_amount = 0
    self.get_main_equipment.each do |item|
      item_attr = item.get_attribute('mining_amount') if item.get_attribute('type') == "Mining Laser" and item.equipped
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['mining_amount_amplifier'] if (Spaceship.ship_variables[name]['trait']['mining_amount_amplifier'] rescue nil) and item_attr
      item_attr = 0 unless item_attr
      mining_amount = mining_amount + item_attr
    end
    mining_amount.round
  end
  
  # Get free main slots
  def get_free_main_slots
    slots = self.get_attribute('main_equipment_slots')
    self.get_equipment.each do |item|
      slots = slots - 1 if item.get_attribute('slot_type') == "main" and item.equipped
    end
    slots
  end
  
  # Get free utility slots
  def get_free_utility_slots
    slots = self.get_attribute('utility_equipment_slots')
    self.get_equipment.each do |item|
      slots = slots - 1 if item.get_attribute('slot_type') == "utility" and item.equipped
    end
    slots
  end
  
  # Get align time
  def get_align_time
    align_time = self.get_attribute('align_time')
    align_time = align_time - (Spaceship.ship_variables[name]['upgrade']['align_amplifier'] ** self.level).round if Spaceship.ship_variables[name]['upgrade']['align_amplifier'] and self.level > 0
    stack = 0
    self.get_equipment.each do |item|
      if item.get_attribute('type') == "Hull" and item.equipped
        item_attr = item.get_attribute('align_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end
      
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['align_amplifier'] if (Spaceship.ship_variables[name]['trait']['align_amplifier'] rescue nil) and item_attr
      item_attr = 0 unless item_attr
      align_time = align_time - align_time * (item_attr / 100)
    end
    align_time.round
  end
  
  # Get target time
  def get_target_time
    target_time = self.get_attribute('target_time')
    target_time = target_time - (Spaceship.ship_variables[name]['upgrade']['target_amplifier'] ** self.level).round if Spaceship.ship_variables[name]['upgrade']['target_amplifier'] and self.level > 0
    stack = 0
    self.get_equipment.each do |item|
      if item.get_attribute('type') == "Sensor" and item.equipped
        item_attr = item.get_attribute('target_amplifier') * Item.stack_penalties[stack]
        stack = stack + 1
      end
      
      item_attr = item_attr * Spaceship.ship_variables[name]['trait']['target_amplifier'] if (Spaceship.ship_variables[name]['trait']['target_amplifier'] rescue nil) and item_attr
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
          item_attr = item.get_attribute('disrupt_strength') if item.get_attribute('type') == "Warp Disruptor" and item.active and item.equipped
          item_attr = item_attr * Spaceship.ship_variables[name]['trait']['warp_disrupt_amplifier'] if (Spaceship.ship_variables[name]['trait']['warp_disrupt_amplifier'] rescue nil) and item_attr
          item_attr = 0 unless item_attr
          weight = weight + (item_attr.round rescue 0)
        end
      end
    end
    self.get_utility_equipment.each do |item|
      weight = weight - item.get_attribute('disrupt_immunity') if item.get_attribute('type') == "Warp Core Stabilizer" and item.equipped
      weight = weight - Spaceship.ship_variables[name]['trait']['disrupt_immunity'] if (Spaceship.ship_variables[name]['trait']['disrupt_immunity'] rescue nil)
    end
    weight > 0? true : false
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
    value = 0
    
    # Add ship
    value = self.get_attribute('price')
    
    # Add for items / equipment
    self.get_items.each do |item|
      value = value + item.get_attribute('price') * item.count
    end
    
    value
  end
  
  # Get Scanner of Ship
  def get_scanner_range
    attribute = 0
    self.get_main_equipment.each do |item|
      attribute = attribute + item.get_attribute('scanner_range') if item.get_attribute('type') == "Scanner"
    end
    attribute = attribute + Spaceship.ship_variables[name]['trait']['scanner_range'] if (Spaceship.ship_variables[name]['trait']['scanner_range'] rescue nil)
    return attribute
  end
  
  # Get HP Color Value
  def get_hp_color
    percentage = self.hp / (Spaceship.ship_variables[name]['hp'] / 100.0)
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
    return true if (Spaceship.ship_variables[name]['trait']['directional_scanner'] rescue false)
    self.get_main_equipment().each do |item|
      return true if item.get_attribute('type') == 'Directional Scanner'
    end
    false
  end
  
  # Check if has jump drive
  def get_jump_drive
    return true if (Spaceship.ship_variables[name]['trait']['jump_drive'] rescue false)
    false
  end
  
  # Get max HP
  def get_max_hp
    hp = Spaceship.ship_variables[name]['hp']
    hp = hp + (Spaceship.ship_variables[name]['upgrade']['hp_amplifier'] ** self.level).round if Spaceship.ship_variables[name]['upgrade']['hp_amplifier'] and self.level > 0
    hp
  end
  
  # Repair
  def repair
    self.update_columns(hp: self.get_max_hp)
  end
  
  # Ship Variables
  def Spaceship.ship_variables
    YAML.load_file("#{Rails.root.to_s}/config/variables/spaceships.yml")
  end
end
