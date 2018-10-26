class GameController < ApplicationController
   def index
      @current_user = User.includes(:system).find(current_user.id)
      @local_messages = ChatMessage.includes(:user).where(system: current_user.system).last(10)
      @global_messages = ChatMessage.includes(:user).where(system: nil).last(10)
      @local_users = User.where(system: current_user.system, online: true)
   end
end