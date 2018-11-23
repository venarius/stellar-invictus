require 'rails_helper'

describe Faction do
  context 'new faction' do
    describe 'attributes' do
      it { should respond_to :name }
      it { should respond_to :description }
      it { should respond_to :users }
      it { should respond_to :location }
    end
   
    describe 'Relations' do
      it { should have_many :users }
      it { should have_one :location }
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
    end
  end
end