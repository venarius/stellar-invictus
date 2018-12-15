class AsteroidsController < ApplicationController
  
  def mine
    # If user can be attacked and is at asteroid field
    if params[:id] and current_user.location.asteroids.present? and current_user.can_be_attacked
      asteroid = Asteroid.find(params[:id]) rescue nil
      
      # If user can't carry ore -> error
      if current_user.active_spaceship.get_weight >= current_user.active_spaceship.get_storage_capacity and asteroid.asteroid_type != 'septarium'
        render json: {error_message: I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
      end
      
      # If user has no mining laser equipped -> error
      if current_user.active_spaceship.get_mining_amount == 0
        render json: {error_message: I18n.t('errors.no_mining_laser')}, status: 400 and return
      end
      
      # If asteroid found and has ressources
      if asteroid and asteroid.resources > 0 and asteroid.location == current_user.location and current_user.mining_target != asteroid
        # Perform Mining Worker
        MiningWorker.perform_async(current_user.id, asteroid.id)
        render json: {name: "#{I18n.t('overview.asteroid')} #{asteroid.asteroid_type.capitalize}", resources: asteroid.resources}, status: 200 and return
      end
      
    end
    render json: {}, status: 400
  end
  
  def stop_mine
    # Stop mining
    current_user.update_columns(mining_target_id: nil)
    render json: {}, status: 200
  end
  
end