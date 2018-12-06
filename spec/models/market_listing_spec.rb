require 'rails_helper'

describe MarketListing do
  context 'new market_listing' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :price }
      it { should respond_to :amount }
      it { should respond_to :loader }
    end
    
    describe 'Relations' do
      it { should belong_to :location }
    end
    
    describe 'Enums' do
       it { should define_enum_for(:listing_type).with([:item, :ship]) } 
    end
    
  end
end