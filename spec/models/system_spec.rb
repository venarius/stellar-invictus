# == Schema Information
#
# Table name: systems
#
#  id              :bigint(8)        not null, primary key
#  name            :string
#  security_status :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_systems_on_name  (name) UNIQUE
#

require 'rails_helper'

describe System do
  context 'new system' do
    describe 'attributes' do
      it { should respond_to :name }
      it { should respond_to :users }
      it { should respond_to :security_status }
      it { should respond_to :locations }
    end

    describe 'Relations' do
      it { should have_many :users }
      it { should have_many :locations }
    end

    describe 'Enums' do
      it { should define_enum_for(:security_status).with_values([:high, :medium, :low, :wormhole]) }
    end

    describe 'Functions' do
      before(:each) do
        @system = create(:system)
      end

      describe 'update_local_players' do
        it 'should broadcast' do
          create(:location, system: @system)
          @system.update_local_players
        end
      end

      describe 'get_faction' do
        it 'should not return faction of first station if station has no faction' do
          expect(System.first.get_faction).to eq(nil)
        end

        it 'should return faction of first station' do
          System.high.first.locations.station.first.update(faction_id: 1)
          expect(System.high.first.get_faction).to eq(Faction.first)
        end
      end

      describe 'mapdata' do
        it 'should return yml file' do
          expect(System.mapdata).to eq(YAML.load_file("#{Rails.root}/config/variables/mapdata.yml"))
        end
      end
    end
  end
end
