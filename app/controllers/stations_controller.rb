class StationsController < ApplicationController
  before_action :check_police, only: [:dock]
  
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
        Spaceship.create(user: current_user, name: params[:name], hp: ship_vars['hp'])
        current_user.update_columns(units: current_user.units - ship_vars['price'])
        flash[:notice] = I18n.t('station.purchase_successfull')
      else
        flash[:alert] = I18n.t('errors.not_enough_units')
      end
    end
  end
  
  def store
    if params[:loader] and params[:amount] and current_user.docked
      amount = params[:amount].to_i
      items = Item.where(spaceship: current_user.active_spaceship, loader: params[:loader])
      if items and amount <= items.count and amount > 0
        items.first(amount).each do |item|
          item.update_columns(spaceship_id: nil, location_id: current_user.location.id, user_id: current_user.id)
        end
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def load
    if params[:loader] and params[:amount] and current_user.docked
      amount = params[:amount].to_i
      items = Item.where(user: current_user, location: current_user.location, loader: params[:loader])
      if amount > current_user.active_spaceship.get_free_weight
        render json: {'error_message': I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
      end
      if items and amount <= items.count and amount > 0
        items.first(amount).each do |item|
          item.update_columns(spaceship_id: current_user.active_spaceship.id, location_id: nil, user_id: nil)
        end
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  private
  
  def check_police
    police = Npc.where(target: current_user.id, npc_type: 'police') rescue nil
    if police.count > 0
      render json: {'error_message' => I18n.t('errors.police_inbound')}, status: 400 and return
    end
  end
end