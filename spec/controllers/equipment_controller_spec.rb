require 'rails_helper'

RSpec.describe EquipmentController, type: :controller do
  context 'with login' do
    let(:user) { create :user_with_faction, docked: true }

    before (:each) do
      sign_in user
    end

    describe 'POST update' do
      let!(:equipment1) { create :item,
          loader: 'equipment.weapons.laser_gatling',
          spaceship: user.active_spaceship,
          equipped: false
      }
      let!(:equipment2) { create :item,
          loader: 'equipment.storage.small_black_hole',
          spaceship: user.active_spaceship,
          equipped: false
      }

      it 'should update equip status of items on main slot' do
        post :update, params: { ids: { "main": [equipment1.loader] } }
        expect(response).to have_http_status(:ok)
        expect(equipment1.reload.equipped).to eq(true)
      end

      it 'should update not equip status of items on utility slot if ship has no slots' do
        post :update, params: { ids: { "utility": [equipment2.loader] } }
        expect(response).to have_http_status(:bad_request)
        expect(equipment2.reload.equipped).to eq(false)
      end

      it 'should update not equip status of items on utility slot if ship has no slots' do
        equipment3 = create(:item, loader: 'equipment.weapons.laser_gatling', spaceship: user.active_spaceship, equipped: false)
        equipment4 = create(:item, loader: 'equipment.weapons.laser_gatling', spaceship: user.active_spaceship, equipped: false)

        post :update, params: { ids: { "main": [equipment1.loader, equipment3.loader, equipment4.loader] } }

        expect(response).to have_http_status(:bad_request)
        expect(equipment1.reload.equipped).to eq(true)
        expect(equipment4.reload.equipped).to eq(false)
      end

      it 'should update equip status of items on utility slot if ship has slots' do
        ship = create(:spaceship, name: 'Valadria', user: user)
        user.update(active_spaceship: ship)
        equipment2.update(spaceship: ship)
        post :update, params: { ids: { "utility": [equipment2.loader] } }
        expect(response).to have_http_status(:ok)
        expect(equipment2.reload.equipped).to eq(true)
      end

      it 'should not update equip status of items if not docked' do
        user.update(docked: false)
        post :update, params: { ids: { "main": [equipment1.loader] } }
        expect(response).to have_http_status(:bad_request)
        expect(equipment1.reload.equipped).to eq(false)
      end

      it 'should update equip status of trying to fit wrong slot but instead fitting it in the right slot' do
        post :update, params: { ids: { "utility": [equipment1.loader] } }
        expect(response).to have_http_status(:ok)
        expect(equipment1.reload.equipped).to eq(true)
      end

      it 'should not update equip status of trying to fit wrong slot' do
        post :update, params: { ids: { "main": [equipment2.loader] } }
        expect(response).to have_http_status(:bad_request)
        expect(equipment2.reload.equipped).to eq(false)
      end

      it 'should O.K but not update equipment on random params given' do
        post :update, params: { ids: { "blub": [equipment2.loader] } }
        expect(response).to have_http_status(:ok)
        expect(equipment2.reload.equipped).to eq(false)
      end

      it 'should fail if item is not in spaceship' do
        equipment1.update(spaceship: nil)
        post :update, params: { ids: { "main": [equipment1.loader] } }
        expect(response).to have_http_status(:bad_request)
        expect(equipment1.reload.equipped).to eq(false)
      end

      it 'should unequip items not listed in params' do
        post :update, params: { ids: { "main": [equipment1.loader] } }
        expect(response).to have_http_status(:ok)
        expect(equipment1.reload.equipped).to eq(true)

        post :update
        expect(response).to have_http_status(:ok)
        expect(user.active_spaceship.reload.items.where(loader: equipment1.loader).count).to eq(1)
      end
    end

    describe 'POST switch' do
      let(:user2) { create :user_with_faction }
      let!(:equipment1) { create(:item, loader: 'equipment.weapons.laser_gatling', spaceship: user.active_spaceship, equipped: true) }

      before(:each) do
        user.update(docked: false, target: user2)
      end

      it 'should activate item on ship' do
        post :switch, params: { id: equipment1.id }
        expect(response).to have_http_status(:ok)
        expect(equipment1.reload.active).to eq(true)
      end

      it 'should activate item on ship and start equipment worker' do
        post :switch, params: { id: equipment1.id }
        expect(response).to have_http_status(:ok)
        expect(equipment1.reload.active).to eq(true)
        expect(EquipmentWorker.jobs.size).to eq(1)
      end

      it 'should not activate item on ship if no params' do
        post :switch
        expect(response).to have_http_status(:bad_request)
        expect(equipment1.reload.active).to eq(false)
      end

      it 'should deactivate active item on ship' do
        equipment1.update(active: true)
        post :switch, params: { id: equipment1.id }
        expect(response).to have_http_status(:ok)
        expect(equipment1.reload.active).to eq(false)
      end
    end
  end
end
