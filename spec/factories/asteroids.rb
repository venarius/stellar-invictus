# == Schema Information
#
# Table name: asteroids
#
#  id            :bigint(8)        not null, primary key
#  asteroid_type :integer
#  resources     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  location_id   :bigint(8)
#
# Indexes
#
#  index_asteroids_on_asteroid_type  (asteroid_type)
#  index_asteroids_on_location_id    (location_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

FactoryBot.define do
  factory :asteroid do
    type { :nickel }
    resources { 1 }
  end
end
