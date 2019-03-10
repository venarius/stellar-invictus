class Faction < ApplicationRecord
  has_many :users
  has_many :missions, dependent: :destroy
  has_many :locations
  
  @faction_variables = YAML.load_file("#{Rails.root.to_s}/config/variables/factions.yml")
  
  # Get Attribute of faction
  def get_attribute(attribute=nil)
    Faction.faction_variables[self.id][attribute] rescue nil
  end
  
  # Get ticker of faction
  def get_ticker
    "[#{Faction.faction_variables[self.id]['ticker']}]"
  end
  
  # Get rank of user
  def get_rank(user)
    reputation = user["reputation_#{self.id}"]
    ranks = Faction.faction_variables['reputation']
    ranks.each do |key, value|
      if reputation >= 0
        return ranks[ranks.keys.last] if reputation >= ranks[ranks.keys.last]['reputation']
        return ranks[key-1] if value['reputation'] > reputation
      else
        return ranks[key] if value['reputation'] >= reputation
      end
    end
  end
  
  # Factions
  def self.faction_variables
    @faction_variables
  end
end
