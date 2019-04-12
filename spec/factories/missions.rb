# == Schema Information
#
# Table name: missions
#
#  id                  :bigint(8)        not null, primary key
#  agent_avatar        :string
#  agent_name          :string
#  deliver_to          :integer
#  difficulty          :integer
#  enemy_amount        :integer
#  faction_bonus       :float
#  faction_malus       :float
#  mission_amount      :integer
#  mission_loader      :string
#  mission_status      :integer
#  mission_type        :integer
#  reward              :integer
#  text                :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  faction_id          :bigint(8)
#  location_id         :bigint(8)
#  mission_location_id :integer
#  user_id             :bigint(8)
#
# Indexes
#
#  index_missions_on_faction_id           (faction_id)
#  index_missions_on_location_id          (location_id)
#  index_missions_on_mission_location_id  (mission_location_id)
#  index_missions_on_mission_type         (mission_type)
#  index_missions_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :mission do
    mission_type { :delivery }
    mission_status { :active }
    agent_name { 'MyString' }
    agent_avatar { 'MyString' }
    text { 1 }
    reward { 1 }
    faction { Faction.all.sample }
    user { nil }
    difficulty { 1 }
    enemy_amount { 1 }
    mission_loader { 'MyString' }
    mission_amount { 1 }
    faction_bonus { 1.5 }
    faction_malus { 1.5 }

    factory :combat_mission do
      mission_type { :combat }
      mission_location { Location.first }
      faction { Faction.first }
      location { Location.first }
    end

  end
end
