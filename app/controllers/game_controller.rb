class GameController < ApplicationController
  before_action :get_local_users, only: [:index, :local_players]
  
  def index
    if current_user.docked 
      redirect_to station_path and return
    end
    @current_user = User.includes(:system).find(current_user.id)
    @local_messages = ChatMessage.includes(:user).where(system: current_user.system).last(10)
    @global_messages = ChatMessage.includes(:user).where(system: nil).last(10)
    @ship_vars = SHIP_VARIABLES[current_user.active_spaceship.name]
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
    render partial: 'players', locals: {local_users: @local_users}
  end
  
  def ship_info
    render partial: 'ship_info', locals: {ship_vars: SHIP_VARIABLES[current_user.active_spaceship.name]}
  end
  
  private
  
  def get_local_users
    @local_users = User.where(location: current_user.location, in_warp: false, docked: false).where("online > 0")
  end
end