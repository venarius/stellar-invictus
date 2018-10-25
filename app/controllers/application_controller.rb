class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_no_faction
  
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :family_name, :email, :password, :password_confirmation])
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
end
