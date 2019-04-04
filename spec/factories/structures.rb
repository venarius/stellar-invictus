# == Schema Information
#
# Table name: structures
#
#  id             :bigint(8)        not null, primary key
#  attempts       :integer          default(0)
#  description    :text
#  name           :string
#  riddle         :integer
#  structure_type :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  location_id    :bigint(8)
#  user_id        :bigint(8)
#
# Indexes
#
#  index_structures_on_location_id     (location_id)
#  index_structures_on_structure_type  (structure_type)
#  index_structures_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :structure do
    structure_type { 0 }
    location { Location.first }
    user { nil }

    factory :monument do
      structure_type { :monument }
      location { Location.first }
    end

  end
end
