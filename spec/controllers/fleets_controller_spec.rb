require 'rails_helper'

RSpec.describe FleetsController, type: :controller do
  context 'without login' do
    describe 'POST invite' do
      it 'should redirect_to new_user_session_path' do
        post :invite
        expect(response.code).to eq("302")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST accept_invite' do
      it 'should redirect_to new_user_session_path' do
        post :accept_invite
        expect(response.code).to eq("302")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
    
  context 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      @user2 = FactoryBot.create(:user_with_faction)
    end
      
    describe 'POST invite' do
      it 'should invite other player if not in fleet' do
        post :invite, params: {id: @user2.id}
        expect(response.status).to eq(200)
        expect(@user.reload.fleet_id).to eq(1)
        expect(Fleet.count).to eq(1)
      end
      
      it 'should not invite other player if no id given' do
        post :invite
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(nil)
        expect(Fleet.count).to eq(0)
      end
      
      it 'should not invite other player if player already in fleet' do
        fleet2 = FactoryBot.create(:fleet, creator: @user2)
        @user2.update_columns(fleet_id: fleet2.id)
        post :invite, params: {id: @user2.id}
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(nil)
        expect(Fleet.count).to eq(1)
      end
      
      it 'should invite other player but not create another fleet if already in fleet' do
        fleet2 = FactoryBot.create(:fleet, creator: @user)
        @user.update_columns(fleet_id: fleet2.id)
        post :invite, params: {id: @user2.id}
        expect(response.status).to eq(200)
        expect(@user.reload.fleet_id).to eq(fleet2.id)
        expect(Fleet.count).to eq(1)
      end
    end
    
    describe 'POST accept_invite' do
      before(:each) do
        @fleet2 = FactoryBot.create(:fleet, creator: @user2)
        @user2.update_columns(fleet_id: @fleet2.id)
      end
      
      it 'should join another fleet' do
        post :accept_invite, params: {id: @fleet2.id}
        expect(response.status).to eq(200)
        expect(@user.reload.fleet_id).to eq(@fleet2.id)
      end
      
      it 'should not join if no id given' do
        post :accept_invite
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(nil)
      end
    end
  end
end