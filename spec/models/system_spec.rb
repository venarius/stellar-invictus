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
       it { should define_enum_for(:security_status).with([:high, :medium, :low, :wormhole]) } 
    end
    
    describe 'Functions' do
      before(:each) do
        @system = FactoryBot.create(:system)
      end
      
      describe 'update_local_players' do
        it 'should broadcast' do
          FactoryBot.create(:location, system: @system)
          @system.update_local_players
        end
      end
      
      describe 'get_faction' do
        it 'should not return faction of first station if station has no faction' do
          expect(System.first.get_faction).to eq(nil)
        end
        
        it 'should return faction of first station' do
          System.where(security_status: :high).first.locations.where(location_type: :station).first.update_columns(faction_id: 1)
          expect(System.where(security_status: :high).first.get_faction).to eq(Faction.first)
        end
      end
      
      describe 'mapdata' do
        it 'should return yml file' do
          expect(System.mapdata).to eq(YAML.load_file("#{Rails.root.to_s}/config/variables/mapdata.yml"))
        end
      end
    end
  end
end
