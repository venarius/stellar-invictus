class Structure < ApplicationRecord
  belongs_to :location
  belongs_to :user, optional: true
  has_many :items, dependent: :destroy
  
  enum structure_type: [:container, :wreck, :abandoned_ship, :monument]
  
  def get_items
    Item.where(structure_id: self.id)
  end
  
  # Riddles
  def self.riddles
    YAML.load_file("#{Rails.root.to_s}/config/variables/riddles.yml")
  end
end
