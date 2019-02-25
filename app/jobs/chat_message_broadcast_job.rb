class ChatMessageBroadcastJob < ApplicationJob  
  queue_as :default

  def perform(chat_message) 
    ChatChannel.broadcast_to(chat_message.chat_room, message: render_message(chat_message))
  end 

  private
  
  def render_message(chat_message) 
    ApplicationController.renderer.render(partial: 'chat_messages/message', locals: { message: chat_message }) 
  end 
end  