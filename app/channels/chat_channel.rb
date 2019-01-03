class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params['room'] == "local_chat"
      stream_for ChatRoom.find_by(system: current_user.reload.system)
    elsif params['room'] == "global_chat"
      stream_for ChatRoom.where(chatroom_type: :global).first
    elsif params['room'].include?("chatroom-")
      room_id = params['room'].gsub("chatroom-", '')
      stream_for ChatRoom.find_by(identifier: room_id)
    end
  end
  
  def send_message(data)
    if data['room'] == "local"
      ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.find_by(system: current_user.reload.system))
    elsif data['room'] == "global"
      ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.where(chatroom_type: :global).first)
    elsif data['room'].include?("chatroom-")
      room_id = data['room'].gsub("chatroom-", '')
      ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.find_by(identifier: room_id))
    end
  end
end