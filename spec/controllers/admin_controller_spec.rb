require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  context 'with login but no admin' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'POST set_credits' do
      it 'should redirect_back' do
        post :set_credits
        expect(response.status).to eq(302)
      end
    end
    
  end
  
  context 'with login and admin' do
    before (:each) do
      $allow_login = true
      @user = FactoryBot.create(:user_with_faction, admin: true)
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should render template' do
        get :index
        expect(response.status).to eq(200)
        expect(response).to render_template('admin/index')
      end
    end
    
    describe 'POST search' do
      it 'should render template' do
        post :search, params: {name: "Gerno"}
        expect(response.status).to eq(200)
        expect(response).to render_template('admin/_search')
      end
      
      it 'should render nothing without params' do
        post :search
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST teleport' do
      it 'should teleport admin to other user' do
        user2 = FactoryBot.create(:user_with_faction, location: Location.last, system: Location.last.system)
        post :teleport, params: {id: user2.id}
        expect(response.status).to eq(200)
        expect(@user.reload.location).to eq(Location.last)
        expect(@user.system).to eq(Location.last.system)
      end
      
      it 'should dock if user to teleport to is docked' do
        user2 = FactoryBot.create(:user_with_faction, location: Location.where(location_type: :station).last, system: Location.where(location_type: :station).last.system, docked: true)
        post :teleport, params: {id: user2.id}
        expect(response.status).to eq(200)
        expect(@user.reload.docked).to eq(true)
        expect(@user.reload.location).to eq(Location.where(location_type: :station).last)
        expect(@user.system).to eq(Location.where(location_type: :station).last.system)
      end
      
      it 'should render nothing without params' do
        post :teleport
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST set_credits' do
      it 'should set_credits of a user' do
        post :set_credits, params: {id: @user.id, credits: 1000}
        expect(response.status).to eq(200)
        expect(@user.reload.units).to eq(1000)
      end
      
      it 'should render nothing without params' do
        post :set_credits
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST ban' do
      before(:each) do
        @user2 = FactoryBot.create(:user_with_faction)
      end
      
      it 'should ban user permanently' do
        post :ban, params: {id: @user2.id, duration: 0, reason: "Test"}
        expect(response.status).to eq(200)
        expect(@user2.reload.banned).to be_truthy
        expect(@user2.banned_until).to eq(nil)
        expect(@user2.banreason).to eq("Test")
      end
      
      it 'should ban user for given hours' do
        post :ban, params: {id: @user2.id, duration: 1, reason: "Test"}
        expect(response.status).to eq(200)
        expect(@user2.reload.banned).to be_truthy
        expect(@user2.banned_until).not_to eq(nil)
        expect(@user2.banreason).to eq("Test")
      end
      
      it 'should render nothing without params' do
        post :ban
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST unban' do
      before(:each) do
        @user2 = FactoryBot.create(:user_with_faction, banned: true, banreason: "Test")
      end
      
      it 'should unban user' do
        post :unban, params: {id: @user2.id}
        expect(response.status).to eq(200)
        expect(@user2.reload.banned).to eq(false)
        expect(@user2.banned_until).to eq(nil)
        expect(@user2.banreason).to eq(nil)
      end
      
      it 'should render nothing without params' do
        post :unban
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST server_message' do
      it 'should send server_message' do
        post :server_message, params: {text: "Test"}
        expect(response.status).to eq(200)
      end
      
      it 'should render nothing without params' do
        post :server_message
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST mute_user' do
      it 'should mute user' do
        post :mute, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(@user.reload.muted).to be_truthy
      end
    end
    
    describe 'POST unmute_user' do
      it 'should unmute user' do
        @user.update_columns(muted: true)
        post :unmute, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(@user.reload.muted).to be_falsey
      end
    end
    
    describe 'POST delete_chat' do
      it 'should delete chat messages of user' do
        ChatMessage.create(user: @user, body: "Test", chat_room: ChatRoom.first)
        post :delete_chat, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(@user.reload.chat_messages.count).to eq(0)
      end
    end
    
    describe 'POST activate_maintenance' do
      it 'should activate maintenance' do
        post :activate_maintenance
        expect(response.status).to eq(204)
        $allow_login = true
      end
      
      describe 'after maintenance' do
        it 'should redirect_to root_path' do
          $allow_login = false
          post :activate_maintenance
          expect(response.status).to eq(302)
          $allow_login = true
        end
      end
    end
    
  end
  
  context 'with ban' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction, banned: true, banreason: "Test")
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should redirect to root path and show flash' do
        get :index
        expect(response.status).to eq(302)
        expect(flash[:notice]).to be_present
      end
      
      it 'should redirect to root path and show flash' do
        @user.update_columns(banned_until: (DateTime.now.to_time + 1.hours).to_datetime)
        get :index
        expect(response.status).to eq(302)
        expect(flash[:notice]).to be_present
      end
      
      it 'should unban if ban is in the past' do
        @user.update_columns(banned_until: (DateTime.now.to_time - 1.hours).to_datetime)
        get :index
        expect(response.status).to eq(302)
      end
    end
  end
end