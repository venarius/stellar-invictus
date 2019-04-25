# == Schema Information
#
# Table name: items
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(FALSE)
#  count        :integer          default(1)
#  equipped     :boolean          default(FALSE)
#  loader       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  location_id  :bigint(8)
#  mission_id   :bigint(8)
#  spaceship_id :bigint(8)
#  structure_id :integer
#  user_id      :bigint(8)
#
# Indexes
#
#  index_items_on_loader        (loader)
#  index_items_on_location_id   (location_id)
#  index_items_on_mission_id    (mission_id)
#  index_items_on_spaceship_id  (spaceship_id)
#  index_items_on_structure_id  (structure_id)
#  index_items_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (spaceship_id => spaceships.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :item do
    user { nil }
    location { nil }
    spaceship { nil }
    loader { 'test' }
  end
end
