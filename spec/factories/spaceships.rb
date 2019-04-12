# == Schema Information
#
# Table name: spaceships
#
#  id             :bigint(8)        not null, primary key
#  custom_name    :string
#  hp             :integer
#  insured        :boolean          default(FALSE)
#  level          :integer          default(0)
#  name           :string
#  warp_scrambled :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  location_id    :bigint(8)
#  user_id        :bigint(8)
#  warp_target_id :integer
#
# Indexes
#
#  index_spaceships_on_location_id  (location_id)
#  index_spaceships_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :spaceship do
    user { create(:user_without_spaceship) }
    name { 'Nano' }
    hp { 50 }
  end
end
