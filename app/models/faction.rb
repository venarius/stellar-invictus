class Faction < ApplicationRecord
  has_many :users
  has_one :location
  
  # Get Attribute of faction
  def get_attribute(attribute=nil)
    FACTION_VARIABLES[self.id][attribute] rescue nil
  end
  
  # Get ticker of faction
  def get_ticker
    "[#{FACTION_VARIABLES[self.id]['ticker']}]"
  end
end
