class Item < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :location, optional: true
  belongs_to :spaceship, optional: true
  belongs_to :structure, optional: true
  belongs_to :mission, optional: true
  
  def get_attribute(attribute)
    atty = self.loader.split(".")
    out = ITEM_VARIABLES[atty[0]]
    self.loader.count('.').times do |i|
      out = out[atty[i+1]]
    end
    out[attribute]
  end
end
