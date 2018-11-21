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
       it { should define_enum_for(:security_status).with([:high, :medium, :low]) } 
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
    end
  end
end
