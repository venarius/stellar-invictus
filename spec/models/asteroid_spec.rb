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

require 'rails_helper'

describe Asteroid do
  context 'new asteroid' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :asteroid_type }
      it { should respond_to :resources }
    end

    describe 'Relations' do
      it { should belong_to :location }
    end

    describe 'Enums' do
      it { should define_enum_for(:asteroid_type).with_values([:nickel, :iron, :cobalt, :septarium, :titanium, :tryon, :lunarium]) }
    end
  end
end
