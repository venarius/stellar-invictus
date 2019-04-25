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
    let(:user) { create :user_with_faction }

    before (:each) do
      sign_in user
    end

    describe 'POST create' do
      it 'should create new room' do
        expect {
          post :create, params: { title: 'Test' }
          expect(response).to have_http_status(:ok)
        }.to change { ChatRoom.count }.by(1)
      end

      it 'shouldnt create new room without params' do
        expect {
          post :create
          expect(response).to have_http_status(:bad_request)
        }.not_to change { ChatRoom.count }
      end

      it 'shouldnt create new room with too long title' do
        expect {
          post :create, params: { title: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { ChatRoom.count }
      end
    end

    describe 'POST join' do
      it 'should fail if chatroom is not custom type' do
        room = ChatRoom.global
        post :join, params: { id: room.identifier }
        expect(response).to have_http_status(:bad_request)
        expect(room.users.count).to eq(0)
      end

      it 'should fail if no params given' do
        post :join
        expect(response).to have_http_status(:bad_request)
        expect(ChatRoom.first.users.count).to eq(0)
      end

      it 'should success if chatroom is custom type' do
        chatroom = create(:chat_room, chatroom_type: :custom)
        post :join, params: { id: chatroom.identifier }
        expect(response).to have_http_status(:ok)
        expect(chatroom.reload.users.count).to eq(1)
      end

      it 'should success if chatroom has fleet' do
        chatroom = create(:chat_room, chatroom_type: :custom)
        fleet = create(:fleet, chat_room: chatroom, creator: user)
        post :join, params: { id: chatroom.identifier }
        expect(response).to have_http_status(:ok)
        expect(chatroom.reload.users.count).to eq(1)
        expect(chatroom.fleet.users.count).to eq(1)
        expect(user.reload.fleet).to eq(fleet)
      end

      it 'should not succeed if user has already joined' do
        chatroom = create(:chat_room, chatroom_type: :custom)
        chatroom.users << user

        post :join, params: { id: chatroom.id }
        expect(response).to have_http_status(:bad_request)
        expect(chatroom.reload.users.count).to eq(1)
      end

      it 'should not succeed if id not found' do
        chatroom = create(:chat_room, chatroom_type: :custom)
        post :join, params: { id: 2000 }
        expect(response).to have_http_status(:bad_request)
        expect(chatroom.reload.users.count).to eq(0)
      end
    end

    describe 'POST leave' do
      let(:room) { create :chat_room, title: 'Test' }
      before(:each) do
        room.users << user
      end

      it 'should not leave room when no id given' do
        post :leave
        expect(response).to have_http_status(:bad_request)
        expect(room.users.count).to eq(1)
      end

      it 'should leave room when id given' do
        expect {
          post :leave, params: { id: room.identifier }
          expect(response).to have_http_status(:ok)
        }.to change { room.users.count }.by(-1)
      end

      it 'should leave room and reset fleet id if room has fleet' do
        create(:fleet, chat_room: room, creator: user)
        expect {
          post :leave, params: { id: room.identifier }
          expect(response).to have_http_status(:ok)
        }.to change { room.users.count }.by(-1)
        expect(room.fleet.users.count).to eq(0)
        expect(user.reload.fleet_id).to eq(nil)
      end

      it 'should not leave room when not in there' do
        expect {
          post :leave, params: { id: room.identifier }
          expect(response).to have_http_status(:ok)
        }.to change { room.users.count }.by(-1)
        expect(room.users.count).to eq(0)

        expect {
          post :leave, params: { id: room.identifier }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { room.users.count }
      end
    end

    describe 'POST start_conversation' do
      it 'should fail if no id given' do
        expect {
          post :start_conversation
          expect(response).to have_http_status(:bad_request)
        }.not_to change { ChatRoom.count }
      end

      it 'should create channel if id given' do
        user2 = create(:user_with_faction)
        expect {
          post :start_conversation, params: { id: user2.id }
          expect(response).to have_http_status(:ok)
        }.to change { ChatRoom.count }.by(1)
      end

      it 'should take existing channel if identifier given' do
        room = create :chat_room, title: 'Test'
        user2 = create :user_with_faction
        expect {
          post :start_conversation, params: { id: user2.id, identifier: room.identifier }
          expect(response).to have_http_status(:ok)
        }.not_to change { ChatRoom.count }
      end

      it 'should fail if inviting self' do
        expect {
          post :start_conversation, params: { id: user.id }
          expect(response).to have_http_status(:bad_request)
        }.not_to change { ChatRoom.count }
      end
    end

    describe 'POST search' do
      it 'should render template if name given' do
        room = ChatRoom.global
        post :search, params: { name: user.name, identifier: room.identifier }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('game/chat/_search')
      end

      it 'should render nothing if no name given' do
        post :search
        expect(response).to have_http_status(:bad_request)
      end
    end

  end
end
