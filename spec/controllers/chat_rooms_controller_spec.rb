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
    
    describe 'POST start_conversation' do
      it 'should redirect to new_user_session_path' do
        post :start_conversation
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      @count = ChatRoom.count
    end
    
    describe 'POST create' do
      it 'should create new room' do
        post :create, params: {title: "Test"}
        expect(response.status).to eq(200)
        expect(ChatRoom.count).to eq(@count+1)
      end
      
      it 'shouldnt create new room without params' do
        post :create
        expect(response.status).to eq(400)
        expect(ChatRoom.count).to eq(@count)
      end
      
      it 'shouldnt create new room with too long title' do
        post :create, params: {title: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}
        expect(response.status).to eq(400)
        expect(ChatRoom.count).to eq(@count)
      end
    end
    
    describe 'POST join' do
      it 'should fail if chatroom is not custom type' do
        post :join, params: {id: ChatRoom.first.identifier}
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
        post :join, params: {id: chatroom.identifier}
        expect(response.status).to eq(200)
        expect(chatroom.reload.users.count).to eq(1)
      end
      
      it 'should success if chatroom has fleet' do
        chatroom = FactoryBot.create(:chat_room, chatroom_type: 2)
        fleet = FactoryBot.create(:fleet, chat_room: chatroom, creator: @user)
        post :join, params: {id: chatroom.identifier}
        expect(response.status).to eq(200)
        expect(chatroom.reload.users.count).to eq(1)
        expect(chatroom.fleet.users.count).to eq(1)
        expect(@user.reload.fleet).to eq(fleet)
      end
      
      it 'should not succeed if user has already joined' do
        chatroom = FactoryBot.create(:chat_room, chatroom_type: 2)
        post :join, params: {id: chatroom.identifier}
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
        post :leave, params: {id: @room.identifier }
        expect(response.status).to eq(200)
        expect(@room.users.count).to eq(0)
      end
      
      it 'should leave room and reset fleet id if room has fleet' do
        FactoryBot.create(:fleet, chat_room: @room, creator: @user)
        post :leave, params: {id: @room.identifier }
        expect(response.status).to eq(200)
        expect(@room.users.count).to eq(0)
        expect(@room.fleet.users.count).to eq(0)
        expect(@user.reload.fleet_id).to eq(nil)
      end
      
      it 'should not leave room when not in there' do
        post :leave, params: {id: @room.identifier }
        expect(response.status).to eq(200)
        expect(@room.users.count).to eq(0)
        post :leave, params: {id: @room.identifier }
        expect(response.status).to eq(400)
        expect(@room.users.count).to eq(0)
      end
    end
    
    describe 'POST start_conversation' do
      it 'should fail if no id given' do
        post :start_conversation
        expect(response.status).to eq(400)
        expect(ChatRoom.count).to eq(@count)
      end
      
      it 'should create channel if id given' do
        user2 = FactoryBot.create(:user_with_faction)
        post :start_conversation, params: {id: user2.id}
        expect(response.status).to eq(200)
        expect(ChatRoom.count).to eq(@count+1)
      end
      
      it 'should take existing channel if identifier given' do
        room = ChatRoom.create(chatroom_type: 'custom', title: 'Test')
        user2 = FactoryBot.create(:user_with_faction)
        post :start_conversation, params: {id: user2.id, identifier: room.identifier}
        expect(response.status).to eq(200)
        expect(ChatRoom.count).to eq(@count+1)
      end
      
      it 'should fail if inviting self' do
        post :start_conversation, params: {id: @user.id}
        expect(response.status).to eq(400)
        expect(ChatRoom.count).to eq(@count)
      end
    end
  end
end