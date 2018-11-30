require 'rails_helper'

RSpec.describe GameMailsController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect_to login' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'GET new' do
      it 'should redirect_to login' do
        get :new
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST create' do
      it 'should redirect_to login' do
        post :create, params: {game_mail: {recipient_name: "Test Test", header: 'Test', body: 'Test'}}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'GET show' do
      it 'should redirect_to login' do
        get :show, params: {id: 1}
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
        expect(response).to render_template('index')
      end
    end
    
    describe 'GET new' do
      it 'should render new' do
        get :new
        expect(response.code).to eq('200')
        expect(response).to render_template('new')
      end
    end
    
    describe 'POST create' do
      it 'should create message' do
        post :create, params: {game_mail: {recipient_name: @user.full_name, body: 'Test', header: 'Test'}}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_mails_path)
        expect(flash[:notice]).to be_present
      end
      
      it 'should not create message with invalid recipient' do
        post :create, params: {game_mail: {recipient_name: 'Test', body: 'Test', header: 'Test'}}
        expect(response.code).to eq('200')
        expect(response).to render_template('new')
        expect(flash[:alert]).to be_present
      end
      
      it 'should pass units to recipient' do
        @user2 = FactoryBot.create(:user_with_faction)
        post :create, params: {game_mail: {recipient_name: @user2.full_name, body: 'Test', header: 'Test', units: 10}}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_mails_path)
        expect(flash[:notice]).to be_present
        expect(@user.reload.units).to eq(990)
        expect(@user2.reload.units).to eq(1010)
      end
      
      it 'should pass units to self' do
        post :create, params: {game_mail: {recipient_name: @user.full_name, body: 'Test', header: 'Test', units: 10}}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_mails_path)
        expect(flash[:notice]).to be_present
        expect(@user.reload.units).to eq(1000)
      end
      
      it 'should not work with negative units' do
        post :create, params: {game_mail: {recipient_name: @user.full_name, body: 'Test', header: 'Test', units: -10}}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_mails_path)
        expect(flash[:notice]).to be_present
        expect(@user.reload.units).to eq(1000)
      end
    end
    
    describe 'GET show' do
      it 'should show message on valid id' do
        @mail = FactoryBot.create(:game_mail, sender: @user, recipient: @user) 
        expect(@mail.read).to be_falsey
        get :show, params: {id: @mail.id}
        expect(response.code).to eq('200')
        expect(response).to render_template('game_mails/_show')
        expect(@mail.reload.read).to be_truthy
      end
      
      it 'should redirect on other id which does not belong to user' do
        @user2 = FactoryBot.create(:user_with_faction)
        @mail = FactoryBot.create(:game_mail, sender: @user2, recipient: @user2) 
        get :show, params: {id: @mail.id}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_mails_path)
      end
      
      it 'should redirect on invalid id' do
        get :show, params: {id: 2000}
        expect(response.code).to eq('302')
        expect(response).to redirect_to(game_mails_path)
      end
    end
  end
end