class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params['room'] == "local_chat"
      stream_for ChatRoom.find_by(location: current_user.location)
    elsif params['room'] == "global_chat"
      stream_for ChatRoom.first
    elsif params['room'].include?("chatroom-")
      room_id = params['room'].gsub("chatroom-", '')
      stream_for ChatRoom.find(room_id.to_i)
    end
  end
  
  def send_message(data)
    if data['room'] == "local"
      ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.find_by(location: current_user.location))
    elsif data['room'] == "global"
      ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.first)
    elsif data['room'].include?("chatroom-")
      room_id = data['room'].gsub("chatroom-", '')
      ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.find(room_id.to_i))
    end
  end
  
  def reload
    stream_for ChatRoom.find_by(location: current_user.reload.location)
  end
end