require 'rails_helper'

RSpec.describe BlueprintsController, type: :controller do
  context 'without login' do
    describe 'POST buy' do
      it 'should redirect_to new_user_session_path' do
        post :buy
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET modal' do
      it 'should redirect_to new_user_session_path' do
        get :modal
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let(:mission_location) { create :location, location_type: :mission, station_type: :research_station }
    let(:user) { create :user_with_faction, location: mission_location, docked: true }

    before(:each) do
      sign_in user
    end

    describe 'GET modal' do
      it 'should render modal' do
        get :modal, params: { type: 'ship', loader: 'Nano' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/blueprints/_shipmodal')
      end

      it 'should render modal' do
        get :modal, params: { type: 'item', loader: 'equipment.weapons.laser_gatling' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/blueprints/_itemmodal')
      end

      it 'should not render modal if no params given' do
        get :modal, params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST buy' do
      it 'should buy blueprint for SHIP if enough credits' do
        user.update(units: 1000)
        expect {
          post :buy, params: { loader: 'Nano', type: 'ship' }
          expect(response).to have_http_status(:ok)
        }.to change { Blueprint.count }.by(1)
      end

      it 'should buy item blueprint for ITEM if enough credits' do
        user.update(units: 10_000_000)
        expect {
          post :buy, params: { loader: Item::EQUIPMENT.sample, type: :item }
          expect(response).to have_http_status(:ok)
        }.to change { Blueprint.count }.by(1)
      end

      it 'should NOT buy blueprint if not enough credits' do
        user.update(units: 1000)
        expect {
          post :buy, params: { loader: 'Valadria', type: 'ship' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Blueprint.count }
      end

      it 'should NOT buy blueprint if not at industrial station' do
        user.update(location_id: Location.where(station_type: 0).first.id, docked: true)
        user.update(units: 1000)
        expect {
          post :buy, params: { loader: 'Nano', type: 'ship' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Blueprint.count }
      end

      it 'should NOT buy blueprint if user not docked' do
        user.update(docked: false)
        user.update(units: 1000)
        expect {
          post :buy, params: { loader: 'Nano', type: 'ship' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Blueprint.count }
      end

      it 'should NOT buy blueprint if user already has blueprint' do
        Blueprint.create(loader: 'Nano', user: user)
        user.update(units: 1000)
        expect {
          post :buy, params: { loader: 'Nano', type: 'ship' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Blueprint.count }
      end
    end

  end
end
