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
    end
    
    describe 'Relations' do
      it { should belong_to :system }
      it { should belong_to :faction }
      it { should have_many :users }
      it { should have_many :asteroids }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:location_type).with([:station, :asteroid_field, :jumpgate]) } 
    end
    
    describe 'Functions' do
      before(:each) do
        @user = FactoryBot.create(:user_with_faction)
      end
      
      describe 'jumpgate' do
        it 'should return associated jumpgate' do
          @location = Location.where(location_type: 'jumpgate').first
          expect(@location.jumpgate).to eq(Jumpgate.first)
        end
      end
      
      describe 'get_items' do
        it 'should return items of current_user in this station' do
          @location = Location.where(location_type: 'station').first
          3.times do
            Item.create(loader: "test", user: @user, location: @location)
          end
          expect(@location.get_items(@user.id)['test']).to eq(3)
        end
        
        it 'should return no items of current_user in this station if has no items' do
          @location = Location.where(location_type: 'station').first
          expect(@location.get_items(@user.id)).to eq({})
        end
      end
    end
  end
end