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
    end
    
    describe 'Relations' do
      it { should have_one :jumpgate }
      it { should belong_to :system }
      it { should belong_to :faction }
      it { should have_many :users }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:location_type).with([:station, :asteroid_field, :jumpgate]) } 
    end
  end
end