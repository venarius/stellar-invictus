require 'rails_helper'

RSpec.describe AsteroidsController, type: :controller do
  context 'with login' do
    let(:asteroid_field) { Location.asteroid_field.first }
    let(:user) { create :user_with_faction, location: asteroid_field }

    before (:each) do
      sign_in user
    end

    describe 'POST mine' do
      it 'should start mine worker when player is attackable and at location and has mining laser equipped' do
        create :item, loader: 'equipment.miner.basic_miner', spaceship: user.active_spaceship, equipped: true
        post :mine, params: { id: user.location.asteroids.first.id }
        expect(response).to have_http_status(:ok)
        expect(MiningWorker.jobs.size).to eq(1)
      end

      it 'should not start mine worker when player is attackable and at location but has no mining laser' do
        post :mine, params: { id: user.location.asteroids.first.id }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end

      it 'should not start when player is docked' do
        user.update(docked: true)
        post :mine, params: { id: user.location.asteroids.first.id }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end

      it 'should not start when player is full' do
        user.active_spaceship.get_storage_capacity.times do
          create :item, spaceship: user.active_spaceship, loader: 'asteroid.nickel_ore'
        end
        create :item, loader: 'equipment.miner.basic_miner', spaceship: user.active_spaceship, equipped: true
        post :mine, params: { id: user.location.asteroids.first.id }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end

      it 'should not start when player is not at this location' do
        post :mine, params: { id: asteroid_field.asteroids.first.id }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end

      it 'should not start when player tries to mine non existant asteroid' do
        post :mine, params: { id: 50000 }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end

      it 'should not start when player is in warp' do
        user.update(in_warp: true)
        post :mine, params: { id: user.location.asteroids.first.id }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end

      it 'should not start when player is full' do
        create_list(:item, 10, spaceship: user.active_spaceship)
        post :mine, params: { id: user.location.asteroids.first.id }
        expect(response).to have_http_status(:bad_request)
        expect(MiningWorker.jobs.size).to eq(0)
      end
    end

    describe 'POST stop_mine' do
      it 'should stop mining' do
        user.update(mining_target_id: Asteroid.first.id)
        expect(user.mining_target).to eq(Asteroid.first)
        post :stop_mine
        expect(response).to have_http_status(:ok)
        expect(user.reload.mining_target).to eq(nil)
      end
    end
  end
end
