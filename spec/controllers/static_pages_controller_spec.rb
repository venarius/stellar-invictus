require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe 'GET home' do
    it 'should render home view' do
      get :home
      expect(response.code).to eq('200')
    end
  end
  
  describe 'GET about' do
    it 'should render about view' do
      get :about
      expect(response.code).to eq('200')
    end
  end
  
  describe 'GET credits' do
    it 'should render credits view' do
      get :credits
      expect(response.code).to eq('200')
    end
  end
end