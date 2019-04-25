# == Schema Information
#
# Table name: npcs
#
#  id          :bigint(8)        not null, primary key
#  hp          :integer
#  name        :string
#  npc_state   :integer
#  npc_type    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint(8)
#  target_id   :integer
#
# Indexes
#
#  index_npcs_on_location_id  (location_id)
#  index_npcs_on_npc_type     (npc_type)
#  index_npcs_on_target_id    (target_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

FactoryBot.define do
  factory :npc do
    npc_type { :enemy }

    factory :npc_police do
      npc_type { :police }
    end
  end
end
