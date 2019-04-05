require 'rails_helper'

RSpec.describe FactoriesController, type: :controller do
  context 'without login' do
    describe 'POST craft' do
      it 'should redirect_to new_user_session_path' do
        post :craft
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
    before(:each) do
      @user = create(:user_with_faction, location_id: Location.where(station_type: 0).first.id, docked: true)
      sign_in @user
    end

    describe 'GET modal' do
      it 'should render modal' do
        get :modal, params: { type: 'ship', loader: 'Nano' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/factory/_shipmodal')
      end

      it 'should render modal' do
        get :modal, params: { type: 'item', loader: 'equipment.weapons.laser_gatling' }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('stations/factory/_itemmodal')
      end

      it 'should not render modal if no params given' do
        get :modal, params: {}
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST craft' do
      it 'should not craft if user not docked' do
        @user.update(docked: false)
        post :craft
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not craft if user doesnt have enough material' do
        post :craft, params: { loader: 'equipment.weapons.laser_gatling', type: 'item', amount: 1 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not craft asteroid ore / else' do
        post :craft, params: { loader: 'asteroid.nickel', type: 'item', amount: 1 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'should not craft more than 100 at the same time' do
        post :craft, params: { loader: 'equipment.weapons.laser_gatling', type: 'item', amount: 101 }
        expect(response).to have_http_status(:bad_request)
        expect(CraftJob.all.count).to eq(0)
      end

      it 'should not start crafting if user doesnt have blueprint' do
        Item.create(loader: 'asteroid.nickel_ore', user: @user, location: @user.location, equipped: false, count: 10)
        Item.create(loader: 'asteroid.cobalt_ore', user: @user, location: @user.location, equipped: false, count: 20)
        Item.create(loader: 'materials.laser_diodes', user: @user, location: @user.location, equipped: false, count: 2)

        post :craft, params: { loader: 'equipment.weapons.laser_gatling', type: 'item', amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(CraftJob.all.count).to eq(0)
      end

      it 'should start crafting if has enough material' do
        Blueprint.create(loader: 'equipment.weapons.laser_gatling', user: @user)

        Item.create(loader: 'asteroid.nickel_ore', user: @user, location: @user.location, equipped: false, count: 10)
        Item.create(loader: 'asteroid.cobalt_ore', user: @user, location: @user.location, equipped: false, count: 20)
        Item.create(loader: 'materials.laser_diodes', user: @user, location: @user.location, equipped: false, count: 2)

        post :craft, params: { loader: 'equipment.weapons.laser_gatling', type: 'item', amount: 1 }
        expect(response).to have_http_status(:ok)
        expect(CraftJob.all.count).to eq(1)
      end

      it 'should start crafting if has enough material' do
        Blueprint.create(loader: 'Nano', user: @user)
        @user.update(location_id: Location.where(station_type: 0).first.id, docked: true)
        Item.create(loader: 'asteroid.nickel_ore', user: @user, location: @user.location, equipped: false, count: 10)
        Item.create(loader: 'asteroid.cobalt_ore', user: @user, location: @user.location, equipped: false, count: 20)
        Item.create(loader: 'materials.laser_diodes', user: @user, location: @user.location, equipped: false, count: 2)

        post :craft, params: { loader: 'Nano', type: 'ship', amount: 1 }
        expect(response).to have_http_status(:ok)
        expect(CraftJob.all.count).to eq(1)
      end

      it 'should not start crafting if has enough material but no blueprint' do
        @user.update(location_id: Location.where(station_type: 0).first.id, docked: true)
        Item.create(loader: 'asteroid.nickel_ore', user: @user, location: @user.location, equipped: false, count: 10)
        Item.create(loader: 'asteroid.cobalt_ore', user: @user, location: @user.location, equipped: false, count: 20)
        Item.create(loader: 'materials.laser_diodes', user: @user, location: @user.location, equipped: false, count: 2)

        post :craft, params: { loader: 'Nano', type: 'ship', amount: 1 }
        expect(response).to have_http_status(:bad_request)
        expect(CraftJob.all.count).to eq(0)
      end
    end
  end
end
