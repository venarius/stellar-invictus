class ChatMessageBroadcastJob < ApplicationJob  
  queue_as :default

  def perform(chat_message) 
    if chat_message.system
      ActionCable.server.broadcast "local_chat_#{chat_message.system.name}", message: render_message(chat_message)
    else
      ActionCable.server.broadcast "global_chat", message: render_message(chat_message)
    end
  end 

  private 
    def render_message(chat_message) 
      ApplicationController.renderer.render(partial: 'chat_messages/message', locals: { message: chat_message }) 
    end 
end  