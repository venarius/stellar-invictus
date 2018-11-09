require 'rails_helper'

describe Spaceship do
  context 'new spaceship' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :name }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
    end
    
    describe 'Functions' do
      before(:each) do
        @ship = FactoryBot.create(:spaceship)
      end
      
      describe 'get_attribute' do
        it 'should return attribute of spaceship from yml' do
          expect(@ship.get_attribute('price')).to eq(0)
        end
        
        it 'should return attribute of spaceship from yml when nil' do
          expect(@ship.get_attribute('noot')).to eq(nil)
        end
      end
      
      describe 'get_items' do
        before(:each) do
          2.times do
            Item.create(loader: 'test', spaceship: @ship)
          end
        end
        
        it 'should return items in storage of ship' do
          expect(@ship.get_items['test']).to eq(2)
        end
      end
    end
  end
end
