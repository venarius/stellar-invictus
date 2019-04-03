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
#  index_missions_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

class Mission < ApplicationRecord
  belongs_to :faction
  belongs_to :user, optional: true
  belongs_to :location

  before_destroy do
    Location.where(mission_id: self.id, location_type: :mission).destroy_all if self.mission_location
  end

  has_one :mission_location, class_name: "Location", dependent: :destroy

  enum mission_type: [:tutorial, :delivery, :combat, :mining, :market, :vip]
  enum mission_status: [:offered, :active, :failed, :completed]
  enum difficulty: [:easy, :medium, :hard]

  delegate :reputation_1, :reputation_2, :reputation_3, to: :user, prefix: true
  delegate :name, to: :faction, prefix: true
end
