require 'rails_helper'

describe Npc do
  context 'new npc' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :npc_type }
      it { should respond_to :target }
      it { should respond_to :hp }
      it { should respond_to :name }
    end
   
    describe 'Relations' do
      it { should belong_to :location }
    end
    
    describe 'Enums' do
      it { should define_enum_for(:npc_type).with([:enemy, :police]) } 
    end
    
    describe 'Functions' do
      before(:each) do
        @npc = FactoryBot.create(:npc, location: Location.first)
      end
      
      describe 'die' do
        it 'should spawn NpcDieWorker' do
          @npc.die
          expect(NpcDiedWorker.jobs.size).to eq(1)
        end
      end
      
      describe 'drop_loot' do
        it 'should create structure and put random loot in it' do
          @npc.drop_loot
          expect(Structure.count).to eq(1)
          expect(Structure.first.get_items.count).to be > 0
        end
      end
    end
  end
end