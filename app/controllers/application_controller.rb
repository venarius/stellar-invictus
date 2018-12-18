class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_no_faction
  before_action :update_last_action
  
  include ApplicationHelper
  
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :family_name, :avatar, :email, :password, :password_confirmation])
  end
  
  def after_sign_in_path_for(resource)
    if current_user.faction
      game_path 
    else
      factions_path  
    end
  end
  
  def redirect_if_no_faction
    if current_user
      redirect_to factions_path unless current_user.faction
    end
  end
  
  def call_police(player)
    player_id = player.id
    
    if player.system.security_status != 'low' and Npc.where(npc_type: 'police', target: player_id).empty?
      if player.system.security_status == 'high'
        PoliceWorker.perform_async(player_id, 2)
      else
        PoliceWorker.perform_async(player_id, 10)
      end
    end
  end
  
  def update_last_action
    if (current_user and current_user.last_action and current_user.last_action < 5.minutes.ago) || (current_user and current_user.last_action == nil)
      current_user.update_columns(last_action: DateTime.now)
    end
  end
end
