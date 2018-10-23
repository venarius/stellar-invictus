require 'rails_helper'

RSpec.describe FactionsController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect_to new_user_session_path' do
        get :index
        expect(response.code).to eq("302")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST choose_faction' do
      it 'should redirect_to new_user_session_path' do
        post :choose_faction, params: {id: 1}
        expect(response.code).to eq("302")
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
      it 'should render index' do
        get :index
        expect(response.code).to eq("200")
        expect(assigns[:factions].length).to eq(3)
      end
      
      it 'should redirect_to game_path if already has faction' do
        sign_in FactoryBot.create(:user, faction: Faction.first)
        
        get :index
        expect(response.code).to eq("302")
        expect(response).to redirect_to(game_path)
      end
    end
      
    describe 'POST choose_faction' do
      it 'should redirect_to game_path' do
        post :choose_faction, params: {id: 1}
        expect(response.code).to eq("302")
        expect(response).to redirect_to(game_path)
        expect(@user.reload.faction_id).to eq(1)
      end
      
      it 'should redirect_to game_path if already has faction' do
        @user = FactoryBot.create(:user, faction: Faction.first)
        sign_in @user
        
        post :choose_faction, params: {id: 2}
        expect(response.code).to eq("302")
        expect(response).to redirect_to(game_path)
        expect(@user.reload.faction_id).to eq(1)
      end
    end
  end
end