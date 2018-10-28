class Location < ApplicationRecord
  belongs_to :system
  has_many :users
  belongs_to :faction, optional: true
  
  enum location_type: [:station, :asteroid_field, :jumpgate]
  
  def jumpgate
    Jumpgate.where("origin_id = ? OR destination_id = ?", self.id, self.id).first
  end
end
