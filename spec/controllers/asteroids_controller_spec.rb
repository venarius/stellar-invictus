require 'rails_helper'

RSpec.describe AsteroidsController, type: :controller do
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'POST mine' do
      it 'should start mine worker when player is attackable and at location and has mining laser equipped' do
        Item.create(loader: "equipment.miner.basic_miner", spaceship: @user.active_spaceship, equipped: true)
        @user.update_columns(location_id: Location.where(location_type: 'asteroid_field').first.id)
        post :mine, params: {id: @user.location.asteroids.first.id}
        expect(response.code).to eq('200')
        expect(MiningWorker.jobs.size).to eq(1)
      end
      
      it 'should not start mine worker when player is attackable and at location but has no mining laser' do
        @user.update_columns(location_id: Location.where(location_type: 'asteroid_field').first.id)
        post :mine, params: {id: @user.location.asteroids.first.id}
        expect(response.code).to eq('400')
        expect(MiningWorker.jobs.size).to eq(0)
      end
      
      it 'should not start when player is docked' do
        @user.update_columns(location_id: Location.where(location_type: 'asteroid_field').first.id, docked: true)
        post :mine, params: {id: @user.location.asteroids.first.id}
        expect(response.code).to eq('400')
        expect(MiningWorker.jobs.size).to eq(0)
      end
      
      it 'should not start when player is not at this location' do
        post :mine, params: {id: Location.where(location_type: 'asteroid_field').first.asteroids.first.id}
        expect(response.code).to eq('400')
        expect(MiningWorker.jobs.size).to eq(0)
      end
      
      it 'should not start when player tries to mine non existant asteroid' do
        @user.update_columns(location_id: Location.where(location_type: 'asteroid_field').first.id)
        post :mine, params: {id: 50000}
        expect(response.code).to eq('400')
        expect(MiningWorker.jobs.size).to eq(0)
      end
      
      it 'should not start when player is in warp' do
        @user.update_columns(location_id: Location.where(location_type: 'asteroid_field').first.id, in_warp: true)
        post :mine, params: {id: @user.location.asteroids.first.id}
        expect(response.code).to eq('400')
        expect(MiningWorker.jobs.size).to eq(0)
      end
      
      it 'should not start when player is full' do
        10.times do
          FactoryBot.create(:item, spaceship: @user.active_spaceship)
        end
        @user.update_columns(location_id: Location.where(location_type: 'asteroid_field').first.id)
        post :mine, params: {id: @user.location.asteroids.first.id}
        expect(response.code).to eq('400')
        expect(MiningWorker.jobs.size).to eq(0)
      end
    end
    
    describe 'POST stop_mine' do
      it 'should stop mining' do
        @user.update_columns(mining_target_id: Asteroid.first.id)
        expect(@user.mining_target).to eq(Asteroid.first)
        post :stop_mine
        expect(response.code).to eq('200')
        expect(@user.reload.mining_target).to eq(nil)
      end
    end
  end
end