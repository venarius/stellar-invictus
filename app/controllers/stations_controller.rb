class StationsController < ApplicationController
  def dock
   if current_user.location.location_type == 'station' and !current_user.docked
     current_user.update_columns(docked: true)
     ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_warp_out', name: current_user.full_name)
   end
  end
  
  def undock
    if current_user.docked
      current_user.update_columns(docked: false)
      ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_appeared')
    end
  end
  
  def index
    unless current_user.docked
      redirect_to game_path
      return
    end
    @ships = SHIP_VARIABLES
    @current_user = User.includes(:system).find(current_user.id)
    @local_messages = ChatMessage.includes(:user).where(system: current_user.system).last(10)
    @global_messages = ChatMessage.includes(:user).where(system: nil).last(10)
  end
end