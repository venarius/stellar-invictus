require 'rails_helper'

describe Faction do
  context 'new faction' do
    describe 'attributes' do
      it { should respond_to :name }
      it { should respond_to :description }
      it { should respond_to :users }
      it { should respond_to :locations }
    end
   
    describe 'Relations' do
      it { should have_many :users }
      it { should have_many :locations }
    end
    
    describe 'Functions' do
      describe 'get_attribute' do
        it 'should return attribute' do
          expect(Faction.first.get_attribute('ticker')).to eq('HEL')
        end
        
        it 'should return nil' do
          expect(Faction.first.get_attribute('noot')).to eq(nil)
        end
      end
      
      describe 'get_ticker' do
        it 'should return ticker' do
          expect(Faction.first.get_ticker).to eq('[HEL]')
        end
      end
      
      describe 'get_rank' do
        it 'should return rank of particular user' do
          user = FactoryBot.create(:user_with_faction, reputation_1: -5, reputation_2: -5, reputation_3: -5)
          expect(Faction.first.get_rank(user)).to eq({"name"=>"Shunned", "reputation"=>-5.0, "type"=>3, "unlocks"=>[]})
        end
      end
    end
  end
end