class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params['room'] == "local_chat"
      stream_for ChatRoom.local.where(system: current_user.reload.system).first
    elsif params['room'] == "global_chat"
      stream_for ChatRoom.global.first
    elsif params['room'].include?("chatroom-")
      room_id = params['room'].gsub("chatroom-", '')
      stream_for ChatRoom.where(identifier: room_id).first
    end
  end

  def send_message(data)
    ap "ChatChannel.send_message"
    ap data
    unless current_user.reload.muted
      if data['room'] == "local"
        ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.local.where(system: current_user.reload.system).first)
      elsif data['room'] == "global"
        ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.global.first)
      elsif data['room'].include?("chatroom-")
        room_id = data['room'].gsub("chatroom-", '')
        ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.where(identifier: room_id).first)
      end
    end
  end
end
