require 'rails_helper'

describe Asteroid do
  context 'new asteroid' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :asteroid_type }
      it { should respond_to :resources }
    end
    
    describe 'Relations' do
      it { should belong_to :location }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:asteroid_type).with([:gold, :bronze, :copper]) } 
    end
  end
end