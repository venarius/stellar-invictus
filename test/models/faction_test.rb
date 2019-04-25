# == Schema Information
#
# Table name: factions
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :bigint(8)
#
# Indexes
#
#  index_factions_on_location_id  (location_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id)
#

require 'test_helper'

class FactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
