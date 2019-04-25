# == Schema Information
#
# Table name: jumpgates
#
#  id             :bigint(8)        not null, primary key
#  traveltime     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  destination_id :integer
#  origin_id      :integer
#
# Indexes
#
#  index_jumpgates_on_destination_id  (destination_id)
#  index_jumpgates_on_origin_id       (origin_id)
#

FactoryBot.define do
  factory :jumpgate do
    origin_id { 1 }
    destination_id { 2 }
    traveltime { 15 }
  end
end
