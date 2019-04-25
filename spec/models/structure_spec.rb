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

require 'rails_helper'

describe Structure do
  context 'new structure' do
    describe 'attributes' do
      it { should respond_to :structure_type }
      it { should respond_to :items }
      it { should respond_to :location }
      it { should respond_to :user }
      it { should respond_to :attempts }
    end

    describe 'Relations' do
      it { should belong_to :location }
      it { should have_many :items }
    end

    describe 'Enum' do
      it { should define_enum_for(:structure_type).with_values([:container, :wreck, :abandoned_ship, :monument]) }
    end

    describe 'Functions' do
      before(:each) do
        @structure = create(:structure, location: Location.first, user: create(:user_with_faction))
      end

      describe 'get_items' do
        before(:each) do
          Item.create(loader: 'test', structure: @structure, count: 2)
        end

        it 'should return items in storage of ship' do
          expect(@structure.get_items.first.count).to eq(2)
        end
      end
    end
  end
end
