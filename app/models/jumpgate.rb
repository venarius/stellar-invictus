class Jumpgate < ApplicationRecord
  validates :traveltime, presence: true, numericality: { only_integer: true }
  
  belongs_to :origin, :foreign_key => "origin_id", :class_name => "Location"
  belongs_to :destination, :foreign_key => "destination_id", :class_name => "Location"
end
