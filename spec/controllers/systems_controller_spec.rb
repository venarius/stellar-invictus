require 'rails_helper'

RSpec.describe SystemsController, type: :controller do
  context 'without login' do
    describe 'GET info' do
      it 'should redirect_to login' do
        get :info, params: { id: 1 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST route' do
      it 'should redirect_to login' do
        post :route
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST clear_route' do
      it 'should redirect_to login' do
        post :clear_route
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST scan' do
      it 'should redirect_to login' do
        post :scan
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let(:system) { System.first }
    let(:user) { create :user_with_faction, location: system.locations.first }
    before(:each) do
      sign_in user
    end

    describe 'GET info' do
      it 'should render template info' do
        get :info, params: { id: 1 }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('systems/_info')
      end

      it 'should respond with 400 if no params' do
        get :info
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST route' do
      it 'should plot route if params given' do
        post :route, params: { id: System.last.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to eq(nil)
      end

      it 'should respond 400 if no params given' do
        post :route
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST clear_route' do
      it 'should clear route of user' do
        user.update(route: ['1', '2', '3'])
        post :clear_route
        expect(response).to have_http_status(:ok)
        expect(user.reload.route).to eq([])
      end
    end

    describe 'POST scan' do
      it 'should render template if user has scanner equipped and is in system where there are exploration sites' do
        Location.create(system: user.system, name: 'Test', location_type: :exploration_site, hidden: true)
        Item.create(loader: 'equipment.scanner.military_scanner', spaceship: user.active_spaceship, equipped: true)
        post :scan
        expect(response).to render_template('game/_locations_table')
      end

      it 'should render not template if user has scanner equipped but no hidden sites' do
        user.system.locations.is_hidden.destroy_all
        Item.create(loader: 'equipment.scanner.military_scanner', spaceship: user.active_spaceship, equipped: true)
        post :scan
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not render template if user has scanner not equipped' do
        Item.create(loader: 'equipment.scanner.military_scanner', spaceship: user.active_spaceship, equipped: false)
        post :scan
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not render template if user has no scanner' do
        post :scan
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST jump_drive' do
      describe 'should SUCCEED if' do
        it 'all is good' do
          user.update(location: System.medium.first.locations.first)
          user.active_spaceship.update(name: 'Atlas')
          post :jump_drive, params: { id: System.all.high.last }
          expect(response).to have_http_status(:ok)
        end
      end

      describe 'should FAIL if' do
        it 'no system id provided' do
          post :jump_drive, params: {}
          expect(response).to have_http_status(:bad_request)
        end

        it 'no jump_drive' do
          post :jump_drive, params: { id: System.all.last }
          expect(response).to have_http_status(:bad_request)
        end

        it 'user cannot be attacked' do
          user.active_spaceship.update(name: 'Atlas')
          user.update(docked: true)
        end

        it "origin system isn't medium or high" do
          user.update(location: System.low.first.locations.first)
          user.active_spaceship.update(name: 'Atlas')
          post :jump_drive, params: { id: System.all.high.last }
          expect(response).to have_http_status(:bad_request)
        end

        it "destination system isn't medium or high" do
          user.update(location: System.medium.first.locations.first)
          user.active_spaceship.update(name: 'Atlas')
          post :jump_drive, params: { id: System.all.low.last }
          expect(response).to have_http_status(:bad_request)
        end

      end

    end
  end

end
