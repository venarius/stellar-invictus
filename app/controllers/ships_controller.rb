class ShipsController < ApplicationController
  def index
    @items = current_user.active_spaceship.get_items
    @active_spaceship = current_user.active_spaceship
  end
  
  def activate
    spaceship = Spaceship.find(params[:id]) rescue nil
    if spaceship and spaceship.user == current_user and current_user.docked and spaceship.location == current_user.location
      current_user.active_spaceship.update_columns(location_id: current_user.location.id)
      current_user.update_columns(active_spaceship_id: spaceship.id)
      spaceship.update_columns(location_id: nil)
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def target
    user = User.find(params[:id]) rescue nil if params[:id]
    if user and user.can_be_attacked and user.location == current_user.location and current_user.can_be_attacked and current_user.target != user
      TargetingWorker.perform_async(current_user.id, user.id)
      render json: {time: current_user.active_spaceship.get_target_time}, status: 200
    else
      render json: {}, status: 400
    end
  end
  
  def untarget
    if current_user.target_id
      ActionCable.server.broadcast("player_#{current_user.target_id}", method: 'stopping_target', name: current_user.full_name)
      current_user.update_columns(target_id: nil, is_attacking: false)
      current_user.active_spaceship.deactivate_equipment
    end
    render json: {}, status: 200
  end
  
  def cargohold
    render partial: 'ships/cargohold', locals: {items: current_user.active_spaceship.get_items(true)}
  end
  
  def info
    if params[:name]
      value = SHIP_VARIABLES[params[:name]]
      render partial: 'ships/info', locals: {value: value, key: params[:name]}
    end
  end
  
  def eject_cargo
    if params[:loader] and params[:amount] and current_user.can_be_attacked
      amount = params[:amount].to_i rescue nil
      
      if amount and amount > 0
        # check amount
        render json: {error_message: I18n.t('errors.you_dont_have_enough_of_this')}, status: 400 and return if Item.where(loader: params[:loader], spaceship: current_user.active_spaceship, equipped: false, active: false).count < amount
        
        EjectCargoWorker.perform_async(current_user.id, params[:loader], amount)
        render json: {}, status: 200 and return
      else
        render json: {error_message: I18n.t('errors.invalid_amount')}, status: 400 and return
      end
    end
    render json: {}, status: 400
  end
end