class AdminController < ApplicationController
  before_action :check_admin
  
  def index
  end
  
  def search
    if params[:name]
      result = User.where("full_name LIKE ?", "%#{params[:name]}%").first(20)
      render partial: 'admin/search', locals: {users: result} and return
    end
    render json: {}, status: 400
  end
  
  def teleport
    if params[:id]
      user = User.find(params[:id]) rescue nil
      if user and !current_user.in_warp
        ActionCable.server.broadcast("location_#{current_user.location_id}", method: 'player_warp_out', name: current_user.full_name)
        old_system = current_user.system
        current_user.update_columns(location_id: user.location_id, system_id: user.system_id, docked: user.docked, in_warp: false)
        # Tell everyone in old system to update their local players
        old_system.update_local_players
        # Tell everyone in new system to update their local players
        current_user.reload.system.update_local_players
        ActionCable.server.broadcast("location_#{current_user.location_id}", method: 'player_appeared')
        ActionCable.server.broadcast("player_#{current_user.id}", method: 'warp_finish')
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
end