class ApplicationController < ActionController::Base
    protect_from_forgery
    before_action :configure_permitted_parameters, if: :devise_controller?
    
    
    protected
    
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :family_name, :email, :password, :password_confirmation])
    end
    
    def after_sign_in_path_for(resource)
        if current_user.faction
            root_path 
        else
            factions_path  
        end
    end
end
