require 'rails_helper'

RSpec.describe FleetsController, type: :controller do
  context 'without login' do
    describe 'POST invite' do
      it 'should redirect_to new_user_session_path' do
        post :invite
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST accept_invite' do
      it 'should redirect_to new_user_session_path' do
        post :accept_invite
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST remove' do
      it 'should redirect_to new_user_session_path' do
        post :remove
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let(:user) { create(:user_with_faction) }
    let(:user2) { create(:user_with_faction) }
    before(:each) do
      sign_in user
    end

    describe 'POST invite' do
      it 'should invite other player if not in fleet' do
        post :invite, params: { id: user2.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.fleet_id).to eq(Fleet.last.id)
        expect(Fleet.count).to eq(1)
      end

      it 'should not invite other player if no id given' do
        post :invite
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.fleet_id).to eq(nil)
        expect(Fleet.count).to eq(0)
      end

      it 'should not invite other player if player already in fleet' do
        fleet2 = create(:fleet, creator: user2)
        user2.update(fleet_id: fleet2.id)
        post :invite, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.fleet_id).to eq(nil)
        expect(Fleet.count).to eq(1)
      end

      it 'should invite other player but not create another fleet if already in fleet' do
        fleet2 = create(:fleet, creator: user)
        user.update(fleet_id: fleet2.id)
        post :invite, params: { id: user2.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.fleet_id).to eq(fleet2.id)
        expect(Fleet.count).to eq(1)
      end
    end

    describe 'POST accept_invite' do
      let(:fleet2) { create :fleet, creator: user2 }
      let(:fleet3) { create :fleet, creator: create(:user_with_faction) }
      before(:each) do
        user2.update(fleet: fleet2)
      end

      it 'should NOT join fleet if already in one' do
        user.update(fleet: fleet3)
        post :accept_invite, params: { id: fleet2.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.fleet_id).to eq(fleet3.id)
      end

      it 'should join fleet' do
        post :accept_invite, params: { id: fleet2.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.fleet_id).to eq(fleet2.id)
      end

      it 'should not join if no id given' do
        post :accept_invite
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.fleet_id).to eq(nil)
      end
    end

    describe 'POST remove' do
      let(:fleet) { create :fleet, creator: user }
      before(:each) do
        user.update(fleet: fleet)
        user2.update(fleet: fleet)
      end

      it 'should be able to remove other user from fleet if fleet creator' do
        post :remove, params: { id: user2.id }
        expect(response).to have_http_status(:ok)
        expect(user2.reload.fleet_id).to eq(nil)
      end

      it 'should not be able to remove other user from fleet if not fleet creator' do
        fleet = create(:fleet, creator: user2)
        user2.update(fleet: fleet)
        user.update(fleet: fleet)
        post :remove, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.fleet_id).to eq(fleet.id)
      end

      it 'should not bet able to remove self from fleet' do
        post :remove, params: { id: user.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.fleet_id).to eq(fleet.id)
      end

      it 'should not bet able to remove user from other fleet' do
        fleet = create(:fleet, creator: user2)
        user2.update(fleet: fleet)
        post :remove, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.fleet_id).to eq(fleet.id)
      end

      it 'should not bet able to remove user with no params given' do
        post :remove
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.fleet_id).to eq(fleet.id)
      end
    end
  end
end
