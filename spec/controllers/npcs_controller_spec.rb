require 'rails_helper'

RSpec.describe NpcsController, type: :controller do
  describe 'without login' do
    describe 'POST target' do
      it 'should redirect to new session path' do
        post :target
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST attack' do
      it 'should redirect to new session path' do
        post :attack
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      @enemy = FactoryBot.create(:npc, location: @user.location, hp: 100)
    end
    
    describe 'POST target' do
      it 'should target npc if user is in same location and can be attacked' do
        post :target, params: {id: @enemy.id}
        expect(response.status).to eq(200)
        expect(TargetNpcWorker.jobs.size).to eq(1)
      end
      
      it 'should not target npc if user is in warp' do
        @user.update_columns(in_warp: true)
        post :target, params: {id: @enemy.id}
        expect(response.status).to eq(400)
        expect(TargetNpcWorker.jobs.size).to eq(0)
      end
      
      it 'should not target npc if npc is not found' do
        post :target, params: {id: 2000}
        expect(response.status).to eq(400)
        expect(TargetNpcWorker.jobs.size).to eq(0)
      end
      
      it 'should not target npc if npc is in another location' do
        @enemy.update_columns(location_id: Location.last.id)
        post :target, params: {id: @enemy.id}
        expect(response.status).to eq(400)
        expect(TargetNpcWorker.jobs.size).to eq(0)
      end
    end
    
    describe 'POST untarget' do
      it 'should remove npc_target_id and is_attacking' do
        @enemy.update_columns(location_id: Location.last.id)
        @user.update_columns(npc_target_id: @enemy.id, is_attacking: true)
        post :untarget
        expect(response.status).to eq(200)
        expect(@user.reload.npc_target_id).to eq(nil)
        expect(@user.is_attacking).to eq(false)
      end
    end
    
    describe 'POST attack' do
      before(:each) do
        @user.update_columns(npc_target_id: @enemy.id)
      end
      
      it 'should attack npc if user is in same location and can be attacked' do
        post :attack, params: {id: @enemy.id}
        expect(response.status).to eq(200)
        expect(AttackNpcWorker.jobs.size).to eq(1)
      end
      
      it 'should not attack npc if user is in warp' do
        @user.update_columns(in_warp: true)
        post :attack, params: {id: @enemy.id}
        expect(response.status).to eq(400)
        expect(AttackNpcWorker.jobs.size).to eq(0)
      end
      
      it 'should not attack npc if npc is not found' do
        post :attack, params: {id: 2000}
        expect(response.status).to eq(400)
        expect(AttackNpcWorker.jobs.size).to eq(0)
      end
      
      it 'should not attack npc if npc is in another location' do
        @enemy.update_columns(location_id: Location.last.id)
        post :attack, params: {id: @enemy.id}
        expect(response.status).to eq(400)
        expect(AttackNpcWorker.jobs.size).to eq(0)
      end
      
      it 'should not attack npc if user has no target' do
        @user.update_columns(npc_target_id: nil)
        post :attack, params: {id: @enemy.id}
        expect(response.status).to eq(400)
        expect(AttackNpcWorker.jobs.size).to eq(0)
      end
      
      it 'should not attack npc if user has other target' do
        enemy2 = FactoryBot.create(:npc, location: @user.location, hp: 100)
        @user.update_columns(npc_target_id: enemy2.id)
        post :attack, params: {id: @enemy.id}
        expect(response.status).to eq(400)
        expect(AttackNpcWorker.jobs.size).to eq(0)
      end
    end
  end
end