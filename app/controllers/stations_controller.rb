class StationsController < ApplicationController
  before_action :check_police, only: [:dock]
  
  def dock
    # If user is at station and not docked
    if current_user.location.location_type == 'station' and !current_user.docked
      # Dock the user
      current_user.dock
      
      # Repair ship
      current_user.active_spaceship.update_columns(hp: current_user.active_spaceship.get_attribute('hp'))
    end
  end
  
  def undock
    # Undock the user
    current_user.undock
  end
  
  def index
    unless current_user.docked
      redirect_to game_path and return
    end
    
    # Set some variables for the view
    @system_users = User.where("online > 0").where(system: current_user.system)
    @ships = current_user.location.get_ships_for_sale
    @current_user = User.includes(:system).find(current_user.id)
    @local_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.find_by(location: current_user.location)).last(10)
    @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.first).last(10)
  end
  
  def buy
    if params[:type] and params[:type] == 'ship' and params[:name]
      if current_user.can_buy_ship(params[:name])
        Spaceship.create(user: current_user, name: params[:name], hp: SHIP_VARIABLES[params[:name]]['hp'])
        current_user.reduce_units(SHIP_VARIABLES[params[:name]]['price'])
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