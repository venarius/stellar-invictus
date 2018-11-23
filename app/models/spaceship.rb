class Spaceship < ApplicationRecord
  belongs_to :user, optional: true
  has_many :items, dependent: :destroy
  
  # Get Weight of all Items in Ship
  def get_weight
    weight = 0
    Item.where(spaceship: self).each do |item|
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
  def get_items
    items = Item.where(spaceship: self)
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
  def get_main_equipment
    items = []
    self.get_equipped_equipment.each do |item|
      items << item if item.get_attribute('slot_type') == "main"
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
  
  # Drop Loot
  def drop_loot
    items = self.get_items
    if items.present?
      structure = Structure.create(location: self.user.location, structure_type: 'wreck')
      items.each do |key, value|
        rand(0..value).times do
          Item.create(loader: key, structure: structure)
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
    power = self.get_attribute('power')
    self.get_main_equipment.each do |item|
      power = power * item.get_attribute('damage_amplifier') if item.get_attribute('type') == "Weapon" and item.equipped
    end
    power = power * self.user.faction.get_attribute('damage_amplifier')
    power.round
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
  
  # Get Defense of ship
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
end
