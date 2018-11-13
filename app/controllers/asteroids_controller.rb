class AsteroidsController < ApplicationController
  
  def mine
    if params[:id] and current_user.location.location_type == 'asteroid_field' and current_user.can_be_attacked
      asteroid = Asteroid.find(params[:id]) rescue nil
      if current_user.active_spaceship.get_weight >= current_user.active_spaceship.get_attribute('storage')
        render json: {error_message: I18n.t('errors.your_ship_cant_carry_that_much')}, status: 400 and return
      end
      if asteroid and asteroid.resources > 0 and asteroid.location == current_user.location
        MiningWorker.perform_async(current_user.id, asteroid.id)
        render json: {name: "#{I18n.t('overview.asteroid')} #{asteroid.asteroid_type.capitalize}", resources: asteroid.resources}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def stop_mine
    current_user.update_columns(mining_target_id: nil)
    render json: {}, status: 200
  end
  
end