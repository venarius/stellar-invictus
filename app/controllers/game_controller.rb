class GameController < ApplicationController
  def index
    @current_user = User.includes(:system).find(current_user.id)
    @local_messages = ChatMessage.includes(:user).where(system: current_user.system).last(10)
    @global_messages = ChatMessage.includes(:user).where(system: nil).last(10)
    @local_users = User.where(location: current_user.location, online: true)
  end
  
  def warp
    if params[:id] && !current_user.in_warp
      location = Location.find(params[:id]) rescue nil
      if location
        WarpWorker.perform_async(current_user.id, location.id)
        render json: {status: 200}
      else
        render json: {status: 400}
      end
    end
  end
end