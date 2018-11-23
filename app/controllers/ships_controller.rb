class ShipsController < ApplicationController
  def index
    @items = current_user.active_spaceship.get_items
    @active_spaceship = current_user.active_spaceship
  end
  
  def activate
    spaceship = Spaceship.find(params[:id]) rescue nil
    if spaceship and spaceship.user == current_user and current_user.docked
      current_user.update_columns(active_spaceship_id: spaceship.id)
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def target
    user = User.find(params[:id]) rescue nil if params[:id]
    if user and user.can_be_attacked and user.location == current_user.location and current_user.can_be_attacked and current_user.target != user
      TargetingWorker.perform_async(current_user.id, user.id)
      render json: {}, status: 200
    else
      render json: {}, status: 400
    end
  end
  
  def untarget
    if current_user.target_id
      ActionCable.server.broadcast("player_#{current_user.target_id}", method: 'getting_targeted', name: current_user.full_name)
      current_user.update_columns(target_id: nil, is_attacking: false)
    end
    render json: {}, status: 200
  end
  
  def attack
    target = User.find(params[:id]) rescue nil if params[:id]
    if target and target.can_be_attacked and current_user.can_be_attacked and target.location == current_user.location and current_user.target == target
      AttackWorker.perform_async(current_user.id, target.id)
      render json: {}, status: 200
    else
      render json: {}, status: 400
    end
  end
  
  def cargohold
    render partial: 'ships/cargohold', locals: {items: current_user.active_spaceship.get_items}
  end
  
  def eject_cargo
    if params[:loader] and current_user.can_be_attacked
      EjectCargoWorker.perform_async(current_user.id, params[:loader])
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
end