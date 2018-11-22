require 'rails_helper'

describe Item do
  context 'new item' do
    describe 'attributes' do
      it { should respond_to :loader }
      it { should respond_to :user }
      it { should respond_to :spaceship }
      it { should respond_to :location }
      it { should respond_to :structure }
      it { should respond_to :equipped }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :spaceship }
      it { should belong_to :location }
      it { should belong_to :structure }
    end
    
    describe 'Functions' do
      describe 'get_attribute' do
        it 'should return attribute of item' do
          @item = Item.create(loader: 'asteroid.iron', user: FactoryBot.create(:user_with_faction))
          expect(@item.get_attribute('weight')).to eq(1)
        end
      end
    end
      
  end
end