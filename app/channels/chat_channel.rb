# frozen_string_literal: true

class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params['room'] == 'local_chat'
      stream_for current_user.system.chat_rooms.local.first
    elsif params['room'] == 'global_chat'
      stream_for ChatRoom.global
    elsif params['room'].include?('chatroom-')
      room_id = params['room'].gsub('chatroom-', '')
      stream_for ChatRoom.ensure(room_id)
    end
  end

  def send_message(data)
    unless current_user.reload.muted
      if data['room'] == 'local'
        room = current_user.system.chat_rooms.local.first
        ChatMessage.create(user: current_user, body: data['message'], chat_room: room).first
      elsif data['room'] == 'global'
        ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.global)
      elsif data['room'].include?('chatroom-')
        room_id = data['room'].gsub('chatroom-', '')
        ChatMessage.create(user: current_user, body: data['message'], chat_room: ChatRoom.ensure(room_id))
      end
    end
  end
end
