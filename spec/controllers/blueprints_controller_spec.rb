require 'rails_helper'

RSpec.describe BlueprintsController, type: :controller do
  context 'without login' do
    describe 'POST buy' do
      it 'should redirect_to new_user_session_path' do
        post :buy
        expect(response.code).to eq("302")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'GET modal' do
      it 'should redirect_to new_user_session_path' do
        get :modal
        expect(response.code).to eq("302")
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
    
  context 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      @user.update_columns(location_id: Location.where(station_type: 3).first.id, docked: true)
    end
    
    describe 'GET modal' do
      it 'should render modal' do
        get :modal, params: {type: 'ship', loader: 'Nano'}
        expect(response.status).to eq(200)
        expect(response).to render_template('stations/blueprints/_shipmodal')
      end
      
      it 'should render modal' do
        get :modal, params: {type: 'item', loader: 'equipment.weapons.laser_gatling'}
        expect(response.status).to eq(200)
        expect(response).to render_template('stations/blueprints/_itemmodal')
      end
      
      it 'should not render modal if no params given' do
        get :modal, params: {}
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST buy' do
      it 'should buy blueprint if enough credits' do
        @user.update_columns(units: 1000)
        post :buy, params: {loader: 'Nano', type: 'ship'}
        expect(response.status).to eq(200)
        expect(Blueprint.count).to eq(1)
      end
      
      it 'should buy item blueprint if enough credits' do
        @user.update_columns(units: 100000)
        post :buy, params: {loader: Item.equipment.sample, type: 'item'}
        expect(response.status).to eq(200)
        expect(Blueprint.count).to eq(1)
      end
      
      it 'should not buy blueprint if not enough credits' do
        @user.update_columns(units: 1000)
        post :buy, params: {loader: 'Valadria', type: 'ship'}
        expect(response.status).to eq(400)
        expect(Blueprint.count).to eq(0)
      end
      
      it 'should not buy blueprint if not at industrial station' do
        @user.update_columns(location_id: Location.where(station_type: 0).first.id, docked: true)
        @user.update_columns(units: 1000)
        post :buy, params: {loader: 'Nano', type: 'ship'}
        expect(response.status).to eq(400)
        expect(Blueprint.count).to eq(0)
      end
      
      it 'should not buy blueprint if user not docked' do
        @user.update_columns(docked: false)
        @user.update_columns(units: 1000)
        post :buy, params: {loader: 'Nano', type: 'ship'}
        expect(response.status).to eq(400)
        expect(Blueprint.count).to eq(0)
      end
      
      it 'should not buy blueprint if user already has blueprint' do
        Blueprint.create(loader: 'Nano', user: @user)
        @user.update_columns(units: 1000)
        post :buy, params: {loader: 'Nano', type: 'ship'}
        expect(response.status).to eq(400)
        expect(Blueprint.count).to eq(1)
      end
    end
    
  end
end