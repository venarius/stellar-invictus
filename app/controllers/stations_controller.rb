class StationsController < ApplicationController
  def dock
    if current_user.location.location_type == 'station' and !current_user.docked
      current_user.update_columns(docked: true, target_id: nil)
      ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_warp_out', name: current_user.full_name)
      User.where(target_id: current_user.id).each do |u|
        u.update_columns(target_id: nil)
        ActionCable.server.broadcast("player_#{u.id}", method: 'refresh_target_info')
      end
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
      redirect_to game_path and return
    end
    @ships = SHIP_VARIABLES
    @current_user = User.includes(:system).find(current_user.id)
    @local_messages = ChatMessage.includes(:user).where(system: current_user.system).last(10)
    @global_messages = ChatMessage.includes(:user).where(system: nil).last(10)
  end
  
  def buy
    if params[:type] and params[:type] == 'ship'
      ship_vars = SHIP_VARIABLES[params[:name]]
      if ship_vars and current_user.units >= ship_vars['price']
        Spaceship.create(user: current_user, name: params[:name])
        current_user.update_columns(units: current_user.units - ship_vars['price'])
        flash[:notice] = I18n.t('station.purchase_successfull')
      else
        flash[:alert] = I18n.t('errors.not_enough_units')
      end
    end
  end
end