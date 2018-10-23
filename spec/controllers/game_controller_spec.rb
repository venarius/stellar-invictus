require 'rails_helper'

RSpec.describe GameController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect_to login' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do 
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should redirect to faction when user has no faction' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(factions_path)
      end
      
      it 'should render the game when user has faction' do
        @user = FactoryBot.create(:user, faction: Faction.first)
        sign_in @user
        
        get :index
        expect(response.code).to eq('200')
      end
    end
  end
end