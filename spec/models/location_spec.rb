# == Schema Information
#
# Table name: locations
#
#  id            :bigint(8)        not null, primary key
#  enemy_amount  :integer          default(0)
#  hidden        :boolean          default(FALSE)
#  location_type :integer
#  name          :string
#  player_market :boolean          default(FALSE)
#  station_type  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  faction_id    :bigint(8)
#  mission_id    :bigint(8)
#  system_id     :bigint(8)
#
# Indexes
#
#  index_locations_on_faction_id     (faction_id)
#  index_locations_on_location_type  (location_type)
#  index_locations_on_mission_id     (mission_id)
#  index_locations_on_name           (name)
#  index_locations_on_station_type   (station_type)
#  index_locations_on_system_id      (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (mission_id => missions.id)
#  fk_rails_...  (system_id => systems.id)
#

require 'rails_helper'

describe Location do
  context 'new location' do
    describe 'attributes' do
      it { should respond_to :users }
      it { should respond_to :system }
      it { should respond_to :location_type }
      it { should respond_to :faction }
      it { should respond_to :jumpgate }
      it { should respond_to :name }
      it { should respond_to :asteroids }
      it { should respond_to :structures }
      it { should respond_to :spaceships }
      it { should respond_to :market_listings }
      it { should respond_to :missions }
    end

    describe 'Relations' do
      it { should belong_to :system }
      it { should have_many :users }
      it { should have_many :asteroids }
      it { should have_many :structures }
      it { should have_many :spaceships }
      it { should have_many :market_listings }
      it { should have_many :missions }
    end

    describe 'Enums' do
      it { should define_enum_for(:location_type).with_values([:station, :asteroid_field, :jumpgate, :mission, :exploration_site, :wormhole]) }
      it { should define_enum_for(:station_type).with_values([:industrial_station, :warfare_plant, :mining_station, :research_station, :trillium_casino]) }
    end

    describe 'Functions' do
      before(:each) do
        @user = create(:user_with_faction)
      end

      describe 'jumpgate' do
        it 'should return associated jumpgate' do
          @location = Location.jumpgate.first
          expect(@location.jumpgate).to eq(Jumpgate.first)
        end
      end

      describe 'get_items' do
        it 'should return items of current_user in this station' do
          @location = Location.station.first
          Item.create(loader: 'test', user: @user, location: @location, count: 3)
          expect(@location.get_items(@user.id).first.count).to eq(3)
        end

        it 'should return no items of current_user in this station if has no items' do
          @location = Location.station.first
          expect(@location.get_items(@user.id)).to eq([])
        end
      end

      describe 'before_destroy' do
        it 'should move users away from self' do
          location = Location.station.first
          user = create(:user_with_faction, location: location)
          location.destroy
          expect(user.reload.location.id).not_to eq(location.id)
        end
      end

      describe 'get_name' do
        it 'should get name of station' do
          location = Location.station.first
          expect(location.get_name).to eq(I18n.t("locations.#{location.station_type}"))
        end

        it 'should get name of jumpgate' do
          location = Location.jumpgate.first
          expect(location.get_name).to eq(location.name)
        end

        it 'should get name of asteroid field' do
          location = Location.asteroid_field.first
          expect(location.get_name).to eq("#{I18n.t("locations.#{location.location_type}")} #{location.name}")
        end
      end
    end
  end
end
