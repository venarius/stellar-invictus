# == Schema Information
#
# Table name: locations
#
#  id            :bigint(8)        not null, primary key
#  enemy_amount  :integer          default(0)
#  hidden        :boolean          default(FALSE)
#  location_type :integer
#  name          :string
#  player_market :boolean          default(FALSE)
#  station_type  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  faction_id    :bigint(8)
#  mission_id    :bigint(8)
#  system_id     :bigint(8)
#
# Indexes
#
#  index_locations_on_faction_id     (faction_id)
#  index_locations_on_location_type  (location_type)
#  index_locations_on_mission_id     (mission_id)
#  index_locations_on_name           (name)
#  index_locations_on_station_type   (station_type)
#  index_locations_on_system_id      (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (system_id => systems.id)
#

FactoryBot.define do
  factory :location do
    name { Faker::Name.first_name }
    system { System.all.sample }
    location_type { :station }
  end
end
