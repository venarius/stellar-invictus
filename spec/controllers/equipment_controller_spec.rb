require 'rails_helper'

RSpec.describe EquipmentController, type: :controller do
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction, docked: true)
      sign_in @user
    end
    
    describe 'POST update' do
      before(:each) do
        @equipment1 = FactoryBot.create(:item, loader: "equipment.weapons.laser_gatling", spaceship: @user.active_spaceship)
        @equipment2 = FactoryBot.create(:item, loader: "equipment.storage.small_black_hole", spaceship: @user.active_spaceship)
      end
      
      it 'should update equip status of items on main slot' do
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.equipped).to be_truthy
      end
      
      it 'should update not equip status of items on utility slot if ship has no slots' do
        post :update, params: {ids: {"utility": [@equipment2.id]}}
        expect(response.status).to eq(400)
        expect(@equipment2.reload.equipped).to be_falsey
      end
      
      it 'should update not equip status of items on utility slot if ship has no slots' do
        @equipment3 = FactoryBot.create(:item, loader: "equipment.weapons.laser_gatling", spaceship: @user.active_spaceship)
        @equipment4 = FactoryBot.create(:item, loader: "equipment.weapons.laser_gatling", spaceship: @user.active_spaceship)
        post :update, params: {ids: {"main": [@equipment1.id, @equipment3.id, @equipment4.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_truthy
        expect(@equipment4.reload.equipped).to be_falsey
      end
      
      it 'should update equip status of items on utility slot if ship has slots' do
        ship = FactoryBot.create(:spaceship, name: "Valadria", user: @user)
        @user.update_columns(active_spaceship_id: ship.id)
        @equipment2.update_columns(spaceship_id: ship.id)
        post :update, params: {ids: {"utility": [@equipment2.id]}}
        expect(response.status).to eq(200)
        expect(@equipment2.reload.equipped).to be_truthy
      end
      
      it 'should not update equip status of items if not docked' do
        @user.update_columns(docked: false)
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_falsey
      end
      
      it 'should not update equip status of trying to fit wrong slot' do
        post :update, params: {ids: {"utility": [@equipment1.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_falsey
      end
      
      it 'should not update equip status of trying to fit wrong slot' do
        post :update, params: {ids: {"main": [@equipment2.id]}}
        expect(response.status).to eq(400)
        expect(@equipment2.reload.equipped).to be_falsey
      end
      
      it 'should fail on random params given' do
        post :update, params: {ids: {"blub": [@equipment2.id]}}
        expect(response.status).to eq(400)
        expect(@equipment2.reload.equipped).to be_falsey
      end
      
      it 'should fail if item is not in spaceship' do
        @equipment1.update_columns(spaceship_id: nil)
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_falsey
      end
      
      it 'should unequip items no listed in params' do
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.equipped).to be_truthy
        post :update
        expect(response.status).to eq(200)
        expect(@equipment1.reload.equipped).to be_falsey
      end
    end
    
    describe 'POST switch' do
      before(:each) do
        user2 = FactoryBot.create(:user_with_faction)
        @user.update_columns(docked: false, target_id: user2.id)
        @equipment1 = FactoryBot.create(:item, loader: "equipment.weapons.laser_gatling", spaceship: @user.active_spaceship, equipped: true)
      end
      
      it 'should activate item on ship' do
        post :switch, params: {id: @equipment1.id}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.active).to be_truthy
      end
      
      it 'should activate item on ship and start equipment worker' do
        post :switch, params: {id: @equipment1.id}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.active).to be_truthy
        expect(EquipmentWorker.jobs.size).to eq(1)
      end
      
      it 'should not activate item on ship if no params' do
        post :switch
        expect(response.status).to eq(400)
        expect(@equipment1.reload.active).to be_falsey
      end
      
      it 'should deactivate active item on ship' do
        @equipment1.update_columns(active: true)
        post :switch, params: {id: @equipment1.id}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.active).to be_falsey
      end
    end
    
    describe 'POST craft' do
      before(:each) do
        @user.update_columns(location_id: Location.where(station_type: 0).first.id, docked: true)
      end
      
      it 'should not craft if user not docked' do
        @user.update_columns(docked: false)
        post :craft
        expect(response.status).to eq(400)
      end
      
      it 'should not craft if user doesnt have enough material' do
        post :craft, params: {loader: 'equipment.weapons.laser_gatling'}
        expect(response.status).to eq(400)
      end
      
      it 'should not craft asteroid ore / else' do
        post :craft, params: {loader: 'asteroid.nickel'}
        expect(response.status).to eq(400)
      end
      
      it 'should start crafting if has enough material' do
        5.times do
          Item.create(loader: 'asteroid.nickel', user: @user, location: @user.location, equipped: false)
        end
        10.times do
          Item.create(loader: 'asteroid.cobalt', user: @user, location: @user.location, equipped: false)
        end
        Item.create(loader: 'materials.laser_diodes', user: @user, location: @user.location, equipped: false)
        
        post :craft, params: {loader: 'equipment.weapons.laser_gatling'}
        expect(response.status).to eq(200)
        expect(CraftJob.all.count).to eq(1)
      end
    end
  end
end