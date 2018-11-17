class Spaceship < ApplicationRecord
  belongs_to :user, optional: true
  has_many :items, dependent: :destroy
  
  def get_weight
    weight = 0
    Item.where(spaceship: self).each do |item|
      weight = weight + item.get_attribute('weight')
    end
    weight
  end
  
  def get_free_weight
    self.get_attribute('storage') - self.get_weight
  end
  
  def get_attribute(attribute)
    SHIP_VARIABLES[self.name][attribute] rescue nil
  end
  
  def get_items
    items = Item.where(spaceship: self)
    storage = Hash.new(0)
    items.each do |value|
      storage[value.loader] += 1
    end
    storage
  end
  
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
end
