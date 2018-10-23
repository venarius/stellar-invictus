class System < ApplicationRecord
  has_many :users
  
  has_many :jumpgates, :foreign_key => "origin_id", 
      :class_name => "Jumpgate"

  has_many :destinations, :through => :jumpgates
  
  enum security_status: [:high, :mid, :low]
end
