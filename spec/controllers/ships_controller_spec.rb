require 'rails_helper'

RSpec.describe ShipsController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect to login page' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
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
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should render index' do
        get :index
        expect(response.code).to eq('200')
        expect(response).to render_template('ships/index')
      end
    end
    
    describe 'POST activate' do
      it 'should not activate other ship if player has none' do
        post :activate, params: {id: 2}
        expect(response.code).to eq('400')
      end
      
      it 'should not activate other ship if player is not docked' do
        FactoryBot.create(:spaceship, user: @user, location: @user.location)
        post :activate, params: {id: 2}
        expect(response.code).to eq('400')
      end
      
      it 'should activate other ship if player is docked' do
        ship = FactoryBot.create(:spaceship, user_id: @user.id, location: @user.location)
        @user.update_columns(docked: true)
        post :activate, params: {id: ship.id}
        expect(response.code).to eq('200')
        expect(@user.reload.active_spaceship).to eq(ship)
      end
      
      it 'should not activate other ship if ship does not belong to player' do
        user = FactoryBot.create(:user_with_faction)
        ship = FactoryBot.create(:spaceship, user_id: user.id)
        @user.update_columns(docked: true)
        post :activate, params: {id: ship.id}
        expect(response.code).to eq('400')
      end
    end
    
    describe 'POST target' do
      it 'should target other player if in same location' do
        user2 = FactoryBot.create(:user_with_faction)
        post :target, params: {id: user2.id}
        expect(response.code).to eq('200')
        expect(TargetingWorker.jobs.size).to eq(1)
      end
      
      it 'should not target other player if target is docked' do
        user2 = FactoryBot.create(:user_with_faction, docked: true)
        post :target, params: {id: user2.id}
        expect(response.code).to eq('400')
        expect(TargetingWorker.jobs.size).to eq(0)
      end
      
      it 'should not target other player if target is in warp' do
        user2 = FactoryBot.create(:user_with_faction, in_warp: true)
        post :target, params: {id: user2.id}
        expect(response.code).to eq('400')
        expect(TargetingWorker.jobs.size).to eq(0)
      end
      
      it 'should not target other player if target is in other location' do
        user2 = FactoryBot.create(:user_with_faction, location_id: 2)
        post :target, params: {id: user2.id}
        expect(response.code).to eq('400')
        expect(TargetingWorker.jobs.size).to eq(0)
      end
    end
    
    describe 'POST untarget' do
      it 'should remove npc_target_id and is_attacking' do
        user2 = FactoryBot.create(:user_with_faction)
        @user.update_columns(target_id: user2.id, is_attacking: true)
        post :untarget
        expect(response.status).to eq(200)
        expect(@user.reload.target_id).to eq(nil)
        expect(@user.is_attacking).to eq(false)
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
          Item.create(spaceship: @user.active_spaceship, loader: 'test')
        end
      end
      
      it 'should start worker' do
        post :eject_cargo, params: {loader: 'test'}
        expect(response.status).to eq(200)
        expect(EjectCargoWorker.jobs.size).to eq(1)
      end
      
      it 'should not start worker if docked' do
        @user.update_columns(docked: true)
        post :eject_cargo, params: {loader: 'test'}
        expect(response.status).to eq(400)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end
      
      it 'should not start worker if in warp' do
        @user.update_columns(in_warp: true)
        post :eject_cargo, params: {loader: 'test'}
        expect(response.status).to eq(400)
        expect(EjectCargoWorker.jobs.size).to eq(0)
      end
    end
    
    describe 'POST craft' do
      before(:each) do
        @user.update_columns(docked: true)
      end
      
      it 'should not craft if user not docked' do
        @user.update_columns(docked: false)
        post :craft
        expect(response.status).to eq(400)
      end
      
      it 'should not craft if user doesnt have enough material' do
        post :craft, params: {name: 'Nano'}
        expect(response.status).to eq(400)
      end
      
      it 'should not craft asteroid ore / else' do
        post :craft, params: {name: 'asteroid.nickel'}
        expect(response.status).to eq(400)
      end
      
      it 'should start crafting if has enough material' do
        @user.update_columns(location_id: Location.where(name: 'Industrial Station').first.id, docked: true)
        5.times do
          Item.create(loader: 'asteroid.nickel', user: @user, location: @user.location, equipped: false)
        end
        10.times do
          Item.create(loader: 'asteroid.cobalt', user: @user, location: @user.location, equipped: false)
        end
        Item.create(loader: 'materials.laser_diodes', user: @user, location: @user.location, equipped: false)
        
        post :craft, params: {name: 'Nano'}
        expect(response.status).to eq(200)
        expect(CraftJob.all.count).to eq(1)
      end
    end
  end
end