require 'rails_helper'

RSpec.describe StationsController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect when user not logged in' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST dock' do
      it 'should redirect when user not logged in' do
        post :dock
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST undock' do
      it 'should redirect when user not logged in' do
        post :undock
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should display index when user is docked' do
        @user.update_columns(docked: true)
        get :index
        expect(response.code).to eq('200')
      end
      
      it 'should redirect_to game when user is not docked' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_path)
      end
    end
    
    describe 'POST dock' do
      it 'should set user to docked if at station' do
        @user.update_columns(location_id: Location.where(location_type: 'station').first.id)
        post :dock
        expect(response.code).to eq('204')
        expect(@user.reload.docked).to be_truthy
      end
      
      it 'should do nothing when user not at station' do
        post :dock
        expect(response.code).to eq('204')
        expect(@user.docked).to be_falsey
      end
    end
    
    describe 'POST undock' do
      it 'should set user to docked false if at station and docked' do
        @user.update_columns(location_id: Location.where(location_type: 'station').first.id, docked: true)
        post :undock
        expect(response.code).to eq('204')
        expect(@user.docked).to eq(true)
      end
      
      it 'should do nothing when user is not docked' do
        post :undock
        expect(response.code).to eq('204')
        expect(@user.docked).to eq(false)
      end
    end
  end
end