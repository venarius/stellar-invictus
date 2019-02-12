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
      it { should define_enum_for(:npc_type).with([:enemy, :police, :politician, :bodyguard, :wanted_enemy]) } 
      it { should define_enum_for(:npc_state).with([:created, :targeting, :attacking, :waiting]) } 
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
          expect(Structure.count).to eq(2)
          expect(Structure.last.get_items.count).to be > 0
        end
      end
      
      describe 'remove_being_targeted' do
        it 'should remove npc as target from others' do
          user = FactoryBot.create(:user_with_faction, npc_target_id: @npc.id)
          @npc.remove_being_targeted
          expect(user.reload.npc_target).to eq(nil)
        end
      end
      
      describe 'give_bounty' do
        it 'should give user random bounty' do
          user = FactoryBot.create(:user_with_faction)
          @npc.give_bounty(user)
          expect(user.reload.units).not_to eq(10)
        end
      end
    end
  end
end