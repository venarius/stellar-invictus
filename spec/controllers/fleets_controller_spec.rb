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

    describe 'POST remove' do
      it 'should redirect_to new_user_session_path' do
        post :remove
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
        post :invite, params: { id: @user2.id }
        expect(response.status).to eq(200)
        expect(@user.reload.fleet_id).to eq(Fleet.last.id)
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
        post :invite, params: { id: @user2.id }
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(nil)
        expect(Fleet.count).to eq(1)
      end

      it 'should invite other player but not create another fleet if already in fleet' do
        fleet2 = FactoryBot.create(:fleet, creator: @user)
        @user.update_columns(fleet_id: fleet2.id)
        post :invite, params: { id: @user2.id }
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
        post :accept_invite, params: { id: @fleet2.id }
        expect(response.status).to eq(200)
        expect(@user.reload.fleet_id).to eq(@fleet2.id)
      end

      it 'should not join if no id given' do
        post :accept_invite
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(nil)
      end
    end

    describe 'POST remove' do
      before(:each) do
        @fleet = FactoryBot.create(:fleet, creator: @user)
        @user.update_columns(fleet_id: @fleet.id)
        @user2.update_columns(fleet_id: @fleet.id)
      end

      it 'should be able to remove other user from fleet if fleet creator' do
        post :remove, params: { id: @user2.id }
        expect(response.status).to eq(200)
        expect(@user2.reload.fleet_id).to eq(nil)
      end

      it 'should not be able to remove other user from fleet if not fleet creator' do
        fleet = FactoryBot.create(:fleet, creator: @user2)
        @user2.update_columns(fleet_id: fleet.id)
        @user.update_columns(fleet_id: fleet.id)
        post :remove, params: { id: @user2.id }
        expect(response.status).to eq(400)
        expect(@user2.reload.fleet_id).to eq(fleet.id)
      end

      it 'should not bet able to remove self from fleet' do
        post :remove, params: { id: @user.id }
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(@fleet.id)
      end

      it 'should not bet able to remove user from other fleet' do
        fleet = FactoryBot.create(:fleet, creator: @user2)
        @user2.update_columns(fleet_id: fleet.id)
        post :remove, params: { id: @user2.id }
        expect(response.status).to eq(400)
        expect(@user2.reload.fleet_id).to eq(fleet.id)
      end

      it 'should not bet able to remove user with no params given' do
        post :remove
        expect(response.status).to eq(400)
        expect(@user.reload.fleet_id).to eq(@fleet.id)
      end
    end
  end
end
