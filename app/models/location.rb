class Location < ApplicationRecord
  belongs_to :system
  has_many :users
  belongs_to :faction, optional: true
  
  has_one :jumpgate, :foreign_key => "origin_id", 
      :class_name => "Jumpgate"
  has_one :jumpgate, :foreign_key => "destination_id", 
      :class_name => "Jumpgate"
  
  enum location_type: [:station, :asteroid_field, :jumpgate]
end
