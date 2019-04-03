# == Schema Information
#
# Table name: factions
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint(8)
#
# Indexes
#
#  index_factions_on_location_id  (location_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

class Faction < ApplicationRecord
  include HasLookupAttributes

  has_many :users
  has_many :missions, dependent: :destroy
  has_many :locations

  @lookup_data = YAML.load_file("#{Rails.root}/config/variables/factions.yml")
  @default_base = :id

  ## — CLASS METHODS

  def self.faction_variables
    @lookup_data
  end

  ## — INSTANCE METHODS

  # Get ticker of faction
  def get_ticker
    "[#{self.get_attribute(:ticker)}]"
  end

  # Get rank of user
  def get_rank(user)
    reputation = user["reputation_#{self.id}"]
    ranks = Faction.faction_variables['reputation']
    ranks.each do |key, value|
      if reputation >= 0
        return ranks[ranks.keys.last] if reputation >= ranks[ranks.keys.last]['reputation']
        return ranks[key - 1] if value['reputation'] > reputation
      else
        return ranks[key] if value['reputation'] >= reputation
      end
    end
  end

end
