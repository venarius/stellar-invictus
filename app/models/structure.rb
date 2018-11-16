class Structure < ApplicationRecord
  belongs_to :location
  belongs_to :user
  has_many :items, dependent: :destroy
  
  enum structure_type: [:container]
  
  def get_items
    items = Item.where(structure_id: self.id)
    storage = Hash.new(0)
    items.each do |value|
      storage[value.loader] += 1
    end
    storage
  end
end
