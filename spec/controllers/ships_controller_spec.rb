require 'rails_helper'

RSpec.describe ShipsController, type: :controller do
  context 'without login' do

    describe 'POST activate' do
      it 'should redirect to login page' do
        post :activate
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST target' do
      it 'should redirect to login page' do
        post :target
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'GET cargohold' do
      it 'should redirect to login page' do
        get :cargohold
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'POST eject_cargo' do
      it 'should redirect to login page' do
        post :eject_cargo
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'with login' do
    let!(:user) { create :user_with_faction }
    before(:each) do
      sign_in user
    end

    describe 'POST activate' do
      it 'should not activate other ship if player has none' do
        post :activate, params: { id: 2 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not activate other ship if player is not docked' do
        create(:spaceship, user: user, location: user.location)
        post :activate, params: { id: 2 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should activate other ship if player is docked' do
        ship = create(:spaceship, user_id: user.id, location: user.location)
        user.update(docked: true)
        post :activate, params: { id: ship.id }
        expect(response).to have_http_status(:ok)
        expect(user.reload.active_spaceship).to eq(ship)
      end

      it 'should not activate other ship if ship does not belong to player' do
        user = create(:user_with_faction)
        ship = create(:spaceship, user_id: user.id)
        user.update(docked: true)
        post :activate, params: { id: ship.id }
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST target' do
      it 'should target other player if in same location' do
        user2 = create(:user_with_faction, location: user.location)
        post :target, params: { id: user2.id }
        expect(response).to have_http_status(:ok)
        expect(TargetingWorker.jobs.size).to eq(1)
      end

      it 'should not target other player if target is docked' do
        user2 = create(:user_with_faction, docked: true)
        post :target, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(TargetingWorker.jobs.size).to eq(0)
      end

      it 'should not target other player if target is in warp' do
        user2 = create(:user_with_faction, in_warp: true)
        post :target, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(TargetingWorker.jobs.size).to eq(0)
      end

      it 'should not target other player if target is in other location' do
        other_location = create :location
        user2 = create(:user_with_faction, location: other_location)
        post :target, params: { id: user2.id }
        expect(response).to have_http_status(:bad_request)
        expect(TargetingWorker.jobs.size).to eq(0)
      end
    end

    describe 'POST untarget' do
      it 'should remove npc_target_id and is_attacking' do
        user2 = create(:user_with_faction)
        user.update(target_id: user2.id, is_attacking: true)
        post :untarget
        expect(response).to have_http_status(:ok)
        expect(user.reload.target_id).to eq(nil)
        expect(user.is_attacking).to eq(false)
      end
    end

    describe 'GET cargohold' do
      it 'should render cargohold' do
        get :cargohold
        expect(response).to render_template('ships/_cargohold')
      end
    end

    describe 'POST eject_cargo' do
      before(:each) do
        2.times do
          Item.create(spaceship: user.active_spaceship, loader: 'test')
        end
      end

      it 'should start worker' do
        post :eject_cargo, params: { loader: 'test', amount: 1 }
        expect(response).to have_http_status(:ok)
        expect(EjectCargoWorker.jobs.size).to eq(1)
      end

      it 'should not start worker if amount missing' do
        post :eject_cargo, params: { loader: 'test' }
        expect(response).to have_http_status(:bad_request)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end

      it 'should not start worker if amount negative' do
        post :eject_cargo, params: { loader: 'test', amount: -1 }
        expect(response).to have_http_status(:bad_request)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end

      it 'should not start worker if amount bigger than what have' do
        post :eject_cargo, params: { loader: 'test', amount: 3 }
        expect(response).to have_http_status(:bad_request)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end

      it 'should not start worker if docked' do
        user.update(docked: true)
        post :eject_cargo, params: { loader: 'test', amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end

      it 'should not start worker if in warp' do
        user.update(in_warp: true)
        post :eject_cargo, params: { loader: 'test', amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end
    end

    describe 'POST insure' do
      before(:each) do
        spaceship = create(:spaceship, name: 'Valadria', hp: '500', user: user)
        user.update(active_spaceship_id: spaceship.id)
      end

      it 'should insure ship' do
        user.update(docked: true, units: 10000)
        post :insure, params: { id: user.active_spaceship.id }
        expect(response).to have_http_status(:ok)
        expect(user.active_spaceship.reload.insured).to be_truthy
      end

      it 'should not insure ship if user is not docked' do
        post :insure, params: { id: user.active_spaceship.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.reload.insured).to be_falsey
      end

      it 'should not insure ship if user has no money' do
        user.update(units: 0)
        post :insure, params: { id: user.active_spaceship.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.reload.insured).to be_falsey
      end

      it 'should not insure already insured ship' do
        user.update(docked: true, units: 10000)
        user.active_spaceship.update(insured: true)
        post :insure, params: { id: user.active_spaceship.id }
        expect(response).to have_http_status(:bad_request)
        expect(user.active_spaceship.reload.insured).to be_truthy
      end
    end

    describe 'POST custom_name' do
      let(:spaceship) { create :spaceship, name: 'Valadria', hp: 500, user: user }
      before(:each) do
        user.update(active_spaceship: spaceship)
      end

      it 'should rename ship' do
        post :custom_name, params: { name: 'Test', id: spaceship.id }
        expect(response).to have_http_status(:ok)
        expect(spaceship.reload.custom_name).to eq('Test')
      end

      it 'should remove custom name of ship' do
        spaceship.update(custom_name: 'Nostromo')
        post :custom_name, params: { name: '', id: spaceship.id }
        expect(response).to have_http_status(:ok)
        expect(spaceship.reload.custom_name).to eq(nil)
      end

      it 'should not rename ship to longer name than 15' do
        post :custom_name, params: { name: 'Testtttttttttttttttttttttttttttttttttt', id: spaceship.id }
        expect(response).to have_http_status(:bad_request)
        expect(spaceship.reload.custom_name).to eq(nil)
      end

      it 'should not rename ship of another user' do
        user2 = create(:user_with_faction)
        spaceship.update(user_id: user2.id)
        post :custom_name, params: { name: 'Test', id: spaceship.id }
        expect(response).to have_http_status(:bad_request)
        expect(spaceship.reload.custom_name).to eq(nil)
      end
    end
  end
end
