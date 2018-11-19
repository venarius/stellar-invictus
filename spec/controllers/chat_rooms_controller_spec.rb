require 'rails_helper'

RSpec.describe ChatRoomsController, type: :controller do
  context 'without login' do
    describe 'POST create' do
      it 'should redirect to new_user_session_path' do
        post :create
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST join' do
      it 'should redirect to new_user_session_path' do
        post :join
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST leave' do
      it 'should redirect to new_user_session_path' do
        post :leave
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'POST create' do
      it 'should create new room' do
        post :create, params: {title: "Test"}
        expect(response.status).to eq(200)
        expect(ChatRoom.count).to eq(13)
      end
      
      it 'shouldnt create new room without params' do
        post :create
        expect(response.status).to eq(400)
        expect(ChatRoom.count).to eq(12)
      end
      
      it 'shouldnt create new room with too long title' do
        post :create, params: {title: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}
        expect(response.status).to eq(400)
        expect(ChatRoom.count).to eq(12)
      end
    end
    
    describe 'POST join' do
      it 'should fail if chatroom is not custom type' do
        post :join, params: {id: ChatRoom.first.id}
        expect(response.status).to eq(400)
        expect(ChatRoom.first.users.count).to eq(0)
      end
      
      it 'should fail if no params given' do
        post :join
        expect(response.status).to eq(400)
        expect(ChatRoom.first.users.count).to eq(0)
      end
      
      it 'should success if chatroom is custom type' do
        chatroom = FactoryBot.create(:chat_room, chatroom_type: 2)
        post :join, params: {id: chatroom.id}
        expect(response.status).to eq(200)
        expect(chatroom.reload.users.count).to eq(1)
      end
      
      it 'should not succeed if user has already joined' do
        chatroom = FactoryBot.create(:chat_room, chatroom_type: 2)
        post :join, params: {id: chatroom.id}
        expect(response.status).to eq(200)
        expect(chatroom.reload.users.count).to eq(1)
        post :join, params: {id: chatroom.id}
        expect(response.status).to eq(400)
        expect(chatroom.reload.users.count).to eq(1)
      end
      
      it 'should not succeed if id not found' do
        chatroom = FactoryBot.create(:chat_room, chatroom_type: 2)
        post :join, params: {id: 2000}
        expect(response.status).to eq(400)
        expect(chatroom.reload.users.count).to eq(0)
      end
    end
    
    describe 'POST leave' do
      before(:each) do
        @room = ChatRoom.create(chatroom_type: 'custom', title: 'Test')
        @room.users << @user
      end
      
      it 'should not leave room when no id given' do
        post :leave
        expect(response.status).to eq(400)
        expect(@room.users.count).to eq(1)
      end
      
      it 'should leave room when id given' do
        post :leave, params: {id: @room.id }
        expect(response.status).to eq(200)
        expect(@room.users.count).to eq(0)
      end
      
      it 'should not leave room when not in there' do
        post :leave, params: {id: @room.id }
        expect(response.status).to eq(200)
        expect(@room.users.count).to eq(0)
        post :leave, params: {id: @room.id }
        expect(response.status).to eq(400)
        expect(@room.users.count).to eq(0)
      end
    end
  end
end