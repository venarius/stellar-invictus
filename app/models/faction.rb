class Faction < ApplicationRecord
  has_many :users
  has_many :missions, dependent: :destroy
  has_many :locations
  
  # Get Attribute of faction
  def get_attribute(attribute=nil)
    FACTION_VARIABLES[self.id][attribute] rescue nil
  end
  
  # Get ticker of faction
  def get_ticker
    "[#{FACTION_VARIABLES[self.id]['ticker']}]"
  end
  
  # Get rank of user
  def get_rank(user)
    reputation = user["reputation_#{self.id}"]
    ranks = FACTION_VARIABLES['reputation']
    ranks.each do |key, value|
      if reputation >= 0
        return ranks[ranks.keys.last] if reputation >= ranks[ranks.keys.last]['reputation']
        return ranks[key-1] if value['reputation'] > reputation
      else
        return ranks[key] if value['reputation'] >= reputation
      end
    end
  end
end
