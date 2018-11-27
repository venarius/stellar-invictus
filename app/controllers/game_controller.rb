class GameController < ApplicationController
  before_action :get_local_users, only: [:index, :local_players]
  before_action :check_police, only: [:warp, :jump]
  before_action :check_warp_disrupt, only: [:warp]
  
  def index
    if current_user.docked 
      redirect_to station_path and return
    end
    @current_user = User.includes(:system).find(current_user.id)
    @system_users = User.where("online > 0").where(system: current_user.system)
    @local_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.find_by(location: current_user.location)).last(10)
    @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.first).last(10)
    @ship_vars = SHIP_VARIABLES[current_user.active_spaceship.name]
  end
  
  def warp
    if params[:id] && !current_user.in_warp
      location = Location.find(params[:id]) rescue nil
      if location && location.system_id == current_user.system_id
        WarpWorker.perform_async(current_user.id, location.id)
        if current_user.active_spaceship.warp_target_id == location.id
          render json: {align_time: 0}, status: 200
        else
          render json: {align_time: current_user.active_spaceship.get_align_time}, status: 200
        end
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
  
  def player_info
    render partial: 'player_info'
  end
  
  private
  
  def get_local_users
    @local_users = User.includes(:faction).where(location: current_user.location, in_warp: false, docked: false).where("online > 0")
  end
  
  def check_police
    police = Npc.where(target: current_user.id, npc_type: 'police') rescue nil
    if police and police.count > 0
      render json: {'error_message' => I18n.t('errors.police_inbound')}, status: 400 and return
    end
  end
  
  def check_warp_disrupt
    if current_user.active_spaceship.is_warp_disrupted
      render json: {'error_message' => I18n.t('errors.warp_disrupted')}, status: 400 and return
    end
  end
end