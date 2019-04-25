require 'rails_helper'

RSpec.describe GameController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect_to login' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST warp' do
      it 'should redirect_to login' do
        post :warp
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST jump' do
      it 'should redirect_to login' do
        post :jump
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET local_players' do
      it 'should redirect_to login' do
        get :local_players
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET player_info' do
      it 'should redirect_to login' do
        get :player_info
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET assets' do
      it 'should redirect_to login' do
        get :assets
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let(:system) { System.first }
    let(:user) { create :user_with_faction, system: system, location: system.locations.first }

    before(:each) do
      sign_in user
    end

    describe 'GET index' do
      it 'should redirect to faction when user has no faction' do
        user = create(:user)
        sign_in user

        get :index
        expect(response).to redirect_to(factions_path)
      end

      it 'should render the game when user has faction' do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it 'should redirect to station when player is docked' do
        user = create(:user_with_faction, docked: true)
        sign_in user

        get :index
        expect(response).to redirect_to(station_path)
      end
    end

    describe 'POST warp' do
      it 'should do nothing with no or invalid id given' do
        post :warp, params: { id: 9999999 }
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should do nothing with id of location in other system given' do
        post :warp, params: { id: System.second.locations.first.id }
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should do nothing when police is engaged' do
        create(:npc_police, target: user)
        post :warp, params: { id: system.locations.second.id }
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should start job with valid id given' do
        post :warp, params: { id: system.locations.second.id }
        expect(WarpWorker.jobs.size).to eq(1)
        expect(response).to have_http_status(:ok)
      end

      it 'should warp to user if in same fleet' do
        user2 = create(:user_with_faction, location: system.locations.last)
        fleet = create(:fleet, creator: user)
        user.update(fleet: fleet)
        user2.update(fleet: fleet)

        post :warp, params: { uid: user2.id }
        expect(WarpWorker.jobs.size).to eq(1)
        expect(response).to have_http_status(:ok)
      end

      it 'should not warp to user if not in fleet' do
        user2 = create(:user_with_faction, location: system.locations.last)

        post :warp, params: { uid: user2.id }
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not warp if not in same system' do
        user2 = create(:user_with_faction, location: System.second.locations.first)
        fleet = create(:fleet, creator: user)
        user.update(fleet: fleet)
        user2.update(fleet: fleet)

        post :warp, params: { uid: user2.id }
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not warp if already there' do
        user2 = create(:user_with_faction, location: user.location)
        fleet = create(:fleet, creator: user)
        user.update(fleet: fleet)
        user2.update(fleet: fleet)

        post :warp, params: { uid: user2.id }
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'GET assets' do
      it 'should render assets' do
        get :assets
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('game/assets')
      end
    end

    describe 'POST jump' do
      it 'should do nothing when user not at jumpgate' do
        user.update(location: Location.station.first)
        post :jump
        expect(JumpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should jump when user at jumpgate' do
        user.update(location: Location.where(system: user.system, location_type: :jumpgate).first)
        post :jump
        expect(JumpWorker.jobs.size).to eq(1)
        expect(response).to have_http_status(:ok)
      end

      it 'should not jump when user at jumpgate but in warp' do
        user.update(location: Location.where(system: user.system, location_type: :jumpgate).first, in_warp: true)
        post :jump
        expect(JumpWorker.jobs.size).to eq(0)
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not jump when user at jumpgate but police is engaged' do
        user.update(location: Location.where(system: user.system, location_type: :jumpgate).first)
        create(:npc_police, target: user)
        post :jump
        expect(response).to have_http_status(:bad_request)
        expect(JumpWorker.jobs.size).to eq(0)
      end
    end

    describe 'GET local_players' do
      it 'should render local players' do
        get :local_players
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('game/_players')
      end
    end

    describe 'GET ship_info' do
      it 'should render ship info' do
        get :ship_info
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('game/_ship_info')
      end
    end

    describe 'GET player_info' do
      it 'should render ship info' do
        get :player_info
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('game/_player_info')
      end
    end
  end
end
