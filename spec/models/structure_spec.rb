require 'rails_helper'

describe Structure do
  context 'new structure' do
    describe 'attributes' do
      it { should respond_to :structure_type }
      it { should respond_to :items }
      it { should respond_to :location }
      it { should respond_to :user }
      it { should respond_to :attempts }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :location }
      it { should have_many :items }
    end
    
    describe 'Enum' do
      it { should define_enum_for(:structure_type).with([:container, :wreck, :abandoned_ship, :monument]) } 
    end
    
    describe 'Functions' do
      before(:each) do
        @structure = FactoryBot.create(:structure, location: Location.first, user: FactoryBot.create(:user_with_faction))
      end
      
      describe 'get_items' do
        before(:each) do
          Item.create(loader: 'test', structure: @structure, count: 2)
        end
        
        it 'should return items in storage of ship' do
          expect(@structure.get_items.first.count).to eq(2)
        end
      end
    end
  end
end