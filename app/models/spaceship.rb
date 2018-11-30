class Spaceship < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  has_many :items, dependent: :destroy
  
  # Get Weight of all Items in Ship
  def get_weight
    weight = 0
    Item.where(spaceship: self, equipped: false).each do |item|
      weight = weight + item.get_attribute('weight')
    end
    weight
  end
  
  # Get free weight
  def get_free_weight
    self.get_storage_capacity - self.get_weight
  end
  
  # Get Attribute of ship
  def get_attribute(attribute=nil)
    SHIP_VARIABLES[self.name][attribute] rescue nil
  end
  
  # Get Items in ship storage
  def get_items(equipped_switch=false)
    if equipped_switch
      items = Item.where(spaceship: self, equipped: false)
    else
      items = Item.where(spaceship: self)
    end
    storage = Hash.new(0)
    items.each do |value|
      storage[value.loader] += 1
    end
    storage
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
      if !active
        items << item if item.get_attribute('slot_type') == "main"
      else
        items << item if item.get_attribute('slot_type') == "main" and item.active
      end
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
  
  # Deactivate Repair Equipment
  def deactivate_repair_equipment
    self.get_equipped_equipment.each do |item|
      item.update_columns(active: false) if item.active and item.get_attribute('type') == "Repair Bot"
    end
  end
  
  # Drop Loot
  def drop_loot
    items = self.get_items
    if items.present?
      structure = Structure.create(location: self.user.location, structure_type: 'wreck')
      items.each do |key, value|
        rand(0..value).times do
          Item.where(loader: key, spaceship: self).first.update_columns(structure_id: structure.id, spaceship_id: nil)
        end
      end
    end
  end
  
  # Get Storage Capacity of Ship
  def get_storage_capacity
    storage = self.get_attribute('storage')
    self.get_utility_equipment.each do |item|
      storage = storage * item.get_attribute('storage_amplifier') if item.get_attribute('type') == "Storage" and item.equipped
    end
    storage = storage * self.user.faction.get_attribute('storage_amplifier')
    storage.round
  end
  
  # Get Power of Ship
  def get_power
    power = 0
    self.get_main_equipment.each do |item|
      power = power + item.get_attribute('damage') if item.get_attribute('type') == "Weapon" and item.equipped and item.active
    end
    power = power * self.user.faction.get_attribute('damage_amplifier')
    power.round
  end
  
  # Get Repair Amount of Ship
  def get_repair
    repair = 0
    self.get_main_equipment.each do |item|
      repair = repair + item.get_attribute('repair_amount') if item.get_attribute('type') == "Repair Bot" and item.equipped and item.active
    end
    repair
  end
  
  # Get Defense of ship
  def get_defense
    defense = self.get_attribute('defense')
    self.get_main_equipment.each do |item|
      defense = defense * item.get_attribute('defense_amplifier') if item.get_attribute('type') == "Defense" and item.equipped
    end
    defense = defense * self.user.faction.get_attribute('defense_amplifier')
    defense.round
  end
  
  # Get Mining Amount of ship
  def get_mining_amount
    mining_amount = 0
    self.get_main_equipment.each do |item|
      mining_amount = (mining_amount + item.get_attribute('mining_amount')) if item.get_attribute('type') == "Mining Laser" and item.equipped
    end
    mining_amount
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
    self.get_equipment.each do |item|
      align_time = (align_time * item.get_attribute('align_amplifier')).round if item.get_attribute('type') == "Hull" and item.equipped
    end
    align_time
  end
  
  # Get target time
  def get_target_time
    target_time = self.get_attribute('target_time')
    self.get_equipment.each do |item|
      target_time = (target_time * item.get_attribute('target_amplifier')).round if item.get_attribute('type') == "Scanner" and item.equipped
    end
    target_time
  end
  
  # Get septarium in storage
  def get_septarium
   Item.where(spaceship: self, loader: 'asteroid.septarium').count
  end
  
  # Get septarium usage
  def get_septarium_usage
    septarium_usage = 0
    self.get_main_equipment(true).each do |item|
      septarium_usage = septarium_usage + item.get_attribute('septarium_usage') if item.get_attribute('slot_type') == "main"
    end
    septarium_usage
  end
  
  # Use septarium
  def use_septarium
    Item.where(spaceship: self, loader: 'asteroid.septarium').limit(self.get_septarium_usage).destroy_all
  end
  
  # If is warp disrupted
  def is_warp_disrupted
    weight = 0
    User.where(target_id: self.user.id, is_attacking: true).each do |user|
      if user.active_spaceship.has_active_warp_disruptor
        user.active_spaceship.get_main_equipment(true).each do |item|
          weight = weight + item.get_attribute('disrupt_strength') if item.get_attribute('type') == "Warp Disruptor" and item.active and item.equipped
        end
      end
    end
    self.get_utility_equipment.each do |item|
      weight = weight - item.get_attribute('disrupt_immunity') if item.get_attribute('type') == "Warp Core Stabilizer" and item.equipped
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
end
