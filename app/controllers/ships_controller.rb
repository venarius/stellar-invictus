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
      ActionCable.server.broadcast("player_#{current_user.target_id}", method: 'getting_targeted', name: current_user.full_name)
      current_user.update_columns(target_id: nil, is_attacking: false)
      current_user.active_spaceship.deactivate_equipment
    end
    render json: {}, status: 200
  end
  
  def cargohold
    render partial: 'ships/cargohold', locals: {items: current_user.active_spaceship.get_items(true)}
  end
  
  def craft
    if params[:name] and current_user.docked and current_user.location.is_factory
      ressources = SHIP_VARIABLES[params[:name]]['crafting'] rescue nil
      if ressources
        # Check if has ressources
        ressources.each do |key, value|
          items = Item.where(loader: key, user: current_user)
          render json: {'error_message': I18n.t('errors.not_required_material')}, status: 400 and return if !items.present? || items.count < value
        end
        
         Delete ressources
        ressources.each do |key, value|
          Item.where(loader: key, user: current_user).limit(value).destroy_all
        end
        
        # Create CraftJob
        CraftJob.create(completion: DateTime.now + (SHIP_VARIABLES[params[:name]]['crafting_duration'].to_f/1440.0), loader: params[:name], user: current_user, location: current_user.location)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def eject_cargo
    if params[:loader] and current_user.can_be_attacked
      EjectCargoWorker.perform_async(current_user.id, params[:loader])
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
end