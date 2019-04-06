require 'rails_helper'

RSpec.describe MissionsController, type: :controller do
  context 'without login' do
    describe 'GET info' do
      it 'should redirect to new_user_session_path' do
        get :info
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST accept' do
      it 'should redirect to new_user_session_path' do
        post :accept
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST finish' do
      it 'should redirect to new_user_session_path' do
        post :finish
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST abort' do
      it 'should redirect to new_user_session_path' do
        post :abort
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET popup' do
      it 'should redirect to new_user_session_path' do
        get :popup
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let(:user) { create :user_with_faction, location_id: Location.station.first.id, docked: true }
    before (:each) do
      sign_in user
      MissionGenerator.generate_missions(user.location.id)
    end

    describe 'GET info' do
      it 'should render template' do
        get :info, params: { id: Mission.last.id }
        expect(response).to render_template('stations/missions/_info')
      end

      it 'should not render template if user not docked' do
        user.update(docked: false)
        get :info, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not render template if mission belongs to other user' do
        user2 = create(:user_with_faction)
        Mission.last.update(mission_status: 1, user_id: user2.id)
        get :info, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST accept' do
      it 'should accept mission' do
        post :accept, params: { id: Mission.last.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.missions.count).to eq(1)
      end

      it 'should not accept mission if mission is already accepted' do
        Mission.last.update(mission_status: 1, user_id: user.id)
        post :accept, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.missions.count).to eq(1)
      end

      it 'should not accept mission if user has already 5 missions' do
        Mission.limit(5).update_all(mission_status: 1, user_id: user.id)
        post :accept, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.missions.count).to eq(5)
      end

      it 'should not accept mission if user is in another location' do
        user.update(location_id: Location.station.last.id)
        post :accept, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.missions.count).to eq(0)
      end
    end

    describe 'GET popup' do
      it 'should render template' do
        get :popup
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/missions/_popup')
      end
    end

    describe 'GET abort' do
      it 'should abort mission' do
        faction_id = Mission.last.faction_id
        Mission.last.update(mission_status: 1, user_id: user.id)
        get :abort, params: { id: Mission.last.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.missions.count).to eq(0)
        expect(user["reputation_#{faction_id}"]).to eq(-0.2)
      end

      it 'should not abort mission if belongs to other user' do
        user2 = create(:user_with_faction)
        Mission.last.update(mission_status: 1, user_id: user2.id)
        get :abort, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
        expect(user2.reload.missions.count).to eq(1)
      end

      it 'should not abort mission if users still on mission site' do
        mission = create(:combat_mission)
        create(:user_with_faction, location: mission.mission_location)
        mission.update(mission_status: 1, user_id: user.id)
        get :abort, params: { id: mission.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.missions.count).to eq(1)
      end
    end

    describe 'POST finish' do
      it 'should not finish mission' do
        Mission.last.update(mission_status: 1, user_id: user.id)
        post :finish, params: { id: Mission.last.id }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should finish mission' do
        Mission.last.update(mission_status: 1, user_id: user.id)
        mission = Mission.last

        mission.update(mission_amount: 0, enemy_amount: 0)

        if mission.delivery?
          user.update(location_id: mission.deliver_to)
          Item::GiveToUser.(amount: mission.mission_amount, loader: mission.mission_loader, user: user, location: user.location)
        elsif mission.market?
          Item::GiveToUser.(amount: mission.mission_amount, loader: mission.mission_loader, user: user, location: user.location)
        end

        post :finish, params: { id: mission.id }
        expect(response).to have_http_status(:ok)
      end
    end

  end
end
