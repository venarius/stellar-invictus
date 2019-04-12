require 'rails_helper'

RSpec.describe StructuresController, type: :controller do
  describe 'without login' do
    describe 'POST open_container' do
      it 'should redirect to new session path' do
        post :open_container
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST pickup_cargo' do
      it 'should redirect to new session path' do
        post :pickup_cargo
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST attack' do
      it 'should redirect to new session path' do
        post :attack
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST abandoned_ship' do
      it 'should redirect to new session path' do
        post :abandoned_ship
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'with login' do
    let(:user)      { create :user_with_faction }
    let(:container) { create :structure, user: user, location: user.location }
    let(:wreck)     { create :structure, user: user, location: user.location, structure_type: :wreck }

    before(:each) do
      sign_in user
    end

    describe 'POST open_container' do
      it 'should render partial on success' do
        post :open_container, params: { id: container.id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('structures/_cargocontainer')
      end

      it 'should render partial for wreck on success' do
        post :open_container, params: { id: wreck.id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('structures/_cargocontainer')
      end

      it 'should fail if container not found' do
        post :open_container, params: { id: 2000 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should fail if container in other location' do
        container.update(location: Location.last)
        post :open_container, params: { id: container.id }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should fail if user docked' do
        user.update(docked: true)
        post :open_container, params: { id: container.id }
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST pickup_cargo' do
      before(:each) do
        create :item, structure: container, loader: 'test', count: 5
      end

      it 'should pickup_cargo and not call police if same user' do
        expect {
          post :pickup_cargo, params: { id: container.id, loader: 'test' }
        }.to change { Structure.count }.by(-1)
        expect(response).to have_http_status(:ok)
        expect(user.reload.active_spaceship.get_weight).to eq(5)
        expect(PoliceWorker.jobs.size).to eq(0)
      end

      it 'should pickup all cargo and not call police if same user' do
        expect {
          post :pickup_cargo, params: { id: container.id }
        }.to change { Structure.count }.by(-1)
        expect(response).to have_http_status(:ok)
        expect(user.reload.active_spaceship.get_weight).to eq(5)
        expect(PoliceWorker.jobs.size).to eq(0)
      end

      it 'should pickup_cargo and call police if not same user' do
        user2 = create(:user_with_faction, location: container.location)
        sign_in user2
        expect {
          post :pickup_cargo, params: { id: container.id, loader: 'test' }
        }.to change { Structure.count }.by(-1)
        expect(response).to have_http_status(:ok)
        expect(user2.reload.active_spaceship.get_weight).to eq(5)
      end

      it 'should not pickup_cargo if docked' do
        user.update(docked: true)
        expect {
          post :pickup_cargo, params: { id: container.id, loader: 'test' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Structure.count }
      end

      it 'should not pickup_cargo user in other location' do
        user.update(location: create(:location, location_type: :station))
        expect {
          post :pickup_cargo, params: { id: container.id, loader: 'test' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Structure.count }
      end

      it 'should not pickup_cargo if user full' do
        create_list :item, 10, spaceship: user.active_spaceship, loader: 'test'
        expect {
          post :pickup_cargo, params: { id: container.id, loader: 'test' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Structure.count }
      end

      it 'should only pickup cargo until user is full' do
        create_list :item, 8, spaceship: user.active_spaceship, loader: 'test'
        expect {
          post :pickup_cargo, params: { id: container.id, loader: 'test' }
          expect(response).to have_http_status(:ok)
        }.not_to change { Structure.count }
        expect(user.reload.active_spaceship.get_weight).to eq(10)
      end
    end

    describe 'POST attack' do
      it 'should destroy and not call police if own container' do
        post :attack, params: { id: container.id }
        expect(response).to have_http_status(:ok)
        expect(Structure.count).to eq(1)
        expect(PoliceWorker.jobs.size).to eq(0)
      end

      it 'should destroy and call police if not own container' do
        user2 = create(:user_with_faction, location: container.location)
        sign_in user2
        expect {
          post :attack, params: { id: container.id }
          expect(response).to have_http_status(:ok)
        }.to change { Structure.count }.by(-1)
      end

      it 'should not destroy if user in other location' do
        container.update(location: create(:location))
        expect {
          post :attack, params: { id: container.id }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { Structure.count }
      end
    end

    describe 'POST abandoned_ship' do
      let(:abandoned_ship) { create :structure, location: user.location, structure_type: :abandoned_ship, riddle: 1 }

      it 'should render_template if user in same location as structure' do
        post :abandoned_ship, params: { id: abandoned_ship.id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('structures/_abandoned_ship')
      end

      it 'should not render_template if user docked' do
        user.update(docked: true)
        post :abandoned_ship, params: { id: abandoned_ship.id }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not render_template if user in warp' do
        user.update(in_warp: true)
        post :abandoned_ship, params: { id: abandoned_ship.id }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not render_template if user in other location' do
        abandoned_ship
        user.update!(location: create(:location, location_type: :asteroid_field))
        post :abandoned_ship, params: { id: abandoned_ship.id }
        expect(response).to have_http_status(:bad_request)
      end

      describe 'structure with items' do
        let!(:item) { create :item, structure: abandoned_ship }

        it 'should fail if false answer given' do
          post :abandoned_ship, params: { id: abandoned_ship.id, text: 'Glub' }
          expect(response).to have_http_status(:bad_request)
        end

        it 'should destroy itself if false answer given for the sixth time' do
          expect {
            6.times do
              post :abandoned_ship, params: { id: abandoned_ship.id, text: 'Glub' }
              expect(response).to have_http_status(:bad_request)
            end
          }.to change { Structure.count }.by(-1)
        end

        it 'should succeed if right answer given' do
          expect {
            post :abandoned_ship, params: { id: abandoned_ship.id, text: '9' }
            expect(response).to have_http_status(:ok)
          }.to change { Structure.count }.by(1)
        end

        it 'should fail if user in other location' do
          user.update(location: create(:location))
          expect {
            post :abandoned_ship, params: { id: abandoned_ship.id, text: '9' }
            expect(response).to have_http_status(:bad_request)
          }.not_to change { Structure.count }
        end
      end
    end

    describe 'GET monument_info' do
      it 'should show modal for monument' do
        monument = create(:monument, location: user.location)
        get :monument_info, params: { id: monument.id }
        expect(response).to render_template('structures/_monument')
      end

      it 'should not show modal if no params given' do
        get :monument_info, params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end

  end
end
