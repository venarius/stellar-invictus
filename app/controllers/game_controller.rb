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
      if location && location.system_id == current_user.system_id
        WarpWorker.perform_async(current_user.id, location.id)
        render json: {}, status: 200
      else
        render json: {}, status: 400
      end
    end
  end
  
  def jump
    if !current_user.in_warp && current_user.location.location_type == 'jumpgate'
      JumpWorker.perform_async(current_user.id)
      render json: {}, status: 200
    else
      render json: {}, status: 400
    end
  end
  
  def local_players
    render partial: 'players', locals: {local_users: User.where(location: current_user.location, online: true)}
  end
end