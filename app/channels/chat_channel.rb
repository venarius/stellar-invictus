class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params['room'] == "local_chat"
      stream_from "local_chat_#{current_user.system.name}"
    else
      stream_from "global_chat"
    end
  end
  
  def send_message(data)
    if params['room'] == "local_chat"
      msg = ChatMessage.new(user: current_user, system: current_user.system, body: data['message'])
      msg.save
    else
      msg = ChatMessage.new(user: current_user, system: nil, body: data['message'])
      msg.save
    end
  end
end