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

class Jumpgate < ApplicationRecord
  validates :traveltime, presence: true, numericality: { only_integer: true }

  belongs_to :origin, foreign_key: :origin_id, class_name: Location.name
  belongs_to :destination, foreign_key: :destination_id, class_name: Location.name
end
