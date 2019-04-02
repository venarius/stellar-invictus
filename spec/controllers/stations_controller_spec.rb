require 'rails_helper'

RSpec.describe StationsController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect when user not logged in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST dock' do
      it 'should redirect when user not logged in' do
        post :dock
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST undock' do
      it 'should redirect when user not logged in' do
        post :undock
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST store' do
      it 'should redirect when user is not logged in' do
        post :store
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST load' do
      it 'should redirect when user is not logged in' do
        post :load
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let(:station) { Location.where(location_type: :station).first }
    let!(:user) { create :user_with_faction, location: station }

    before(:each) do
      sign_in user
    end

    describe 'GET index' do
      it 'should display index when user is docked' do
        user.update(docked: true)
        get :index
        expect(response.code).to eq('200')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'overview' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_overview')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'my_ships' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_my_ships')
        expect(assigns(:user_ships).count).to eq(0)
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'active_ship' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_active_ship')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'bounty_office' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_bounty_office')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'storage' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_storage')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'factory' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_factory')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'market' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_market')
      end

      it 'should display tab when user is docked' do
        user.update(docked: true)
        get :index, params: { tab: 'missions' }
        expect(response.code).to eq('200')
        expect(response).to render_template('stations/_missions')
        expect(Mission.count).to eq(6)
      end

      it 'should redirect_to game when user is not docked' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_path)
      end
    end

    describe 'POST dock' do
      it 'should set user to docked if at station' do
        post :dock
        expect(response).to have_http_status(:no_content)
        expect(user.reload.docked).to eq(true)
      end

      it 'should do nothing when user not at station' do
        post :dock
        expect(response).to have_http_status(:no_content)
        expect(user.docked).to eq(false)
      end

      it 'should do nothing when police is engaged' do
        FactoryBot.create(:npc_police, target_user: user)
        post :dock
        expect(response).to have_http_status(:bad_request)
        expect(user.docked).to eq(false)
      end

      it 'should remove user as target of other users' do
        user2 = FactoryBot.create(:user_with_faction)
        user2.update(target: user)

        expect(user2.target).to eq(user)
        post :dock
        expect(response).to have_http_status(:no_content)
        expect(user.reload.docked).to eq(true)
        expect(user2.reload.target_id).to eq(nil)
      end

      it 'should refuse request if user standing below or eq -10 with faction' do
        faction_station = Location.where(location_type: 'station').where(faction_id: 1).first
        user.update(location: faction_station)
        user.update(reputation_1: -10)
        post :dock
        expect(response).to have_http_status(:bad_request)
        expect(user.reload.docked).to eq(false)
      end
    end

    describe 'POST undock' do
      it 'should set user to docked false if at station and docked' do
        user.update(docked: true)
        post :undock
        expect(response).to have_http_status(:no_content)
        expect(user.docked).to eq(true)
      end

      it 'should do nothing when user is not docked' do
        post :undock
        expect(response).to have_http_status(:no_content)
        expect(user.docked).to eq(false)
      end
    end

    describe 'POST store' do
      before(:each) do
        user.update(docked: true)
        Item.create(loader: 'test', spaceship: user.active_spaceship, equipped: false, count: 3)
      end

      it 'should store items in station' do
        expect(user.active_spaceship.get_weight).to eq(3)
        post :store, params: { loader: 'test', amount: 3 }
        expect(response.code).to eq('200')
        expect(user.active_spaceship.get_weight).to eq(0)
        expect(user.location.items.count).to eq(1)
        expect(user.location.items.first.count).to eq(3)
      end

      it 'should not store more items in station than player has' do
        expect(user.active_spaceship.get_weight).to eq(3)
        post :store, params: { loader: 'test', amount: 4 }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.get_weight).to eq(3)
        expect(user.location.items.count).to eq(0)
      end

      it 'should not store less items in station than 0' do
        expect(user.active_spaceship.get_weight).to eq(3)
        post :store, params: { loader: 'test', amount: -1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.get_weight).to eq(3)
        expect(user.location.items.count).to eq(0)
      end
    end

    describe 'POST load' do

      before(:each) do
        user.update(docked: true)
        Item.create(loader: 'test', user: user, location: user.location, equipped: false, count: 3)
      end

      it 'should store items in ship' do
        expect(user.location.items.count).to eq(1)
        post :load, params: { loader: 'test', amount: 3 }
        expect(response.code).to eq('200')
        expect(user.active_spaceship.get_weight).to eq(3)
        expect(user.location.items.count).to eq(0)
      end

      it 'should not store more items in ship than player has' do
        expect(user.location.items.count).to eq(1)
        post :load, params: { loader: 'test', amount: 4 }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.get_weight).to eq(0)
        expect(user.location.items.count).to eq(1)
      end

      it 'should not store less items in ship than 0' do
        expect(user.location.items.count).to eq(1)
        post :load, params: { loader: 'test', amount: -1 }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.get_weight).to eq(0)
        expect(user.location.items.count).to eq(1)
      end

      it 'should not store more items in ship than ship can carry' do
        Item.create(loader: 'test', user: user, location: user.location, count: 10)
        expect(user.location.items.count).to eq(2)
        post :load, params: { loader: 'test', amount: 13 }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.get_weight).to eq(0)
        expect(user.location.items.count).to eq(2)
      end
    end
  end
end
