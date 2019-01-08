class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_no_faction
  before_action :update_last_action
  before_action :check_banned
  before_action :check_maintenance
  
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
  
  def check_docked
    render json: {}, status: 400 and return unless current_user.docked
  end
  
  def check_admin
    redirect_back(fallback_location: root_path) unless current_user.admin
  end
  
  def check_banned
    if current_user.present? and current_user.banned
      if current_user.banned_until
        if current_user.banned_until > DateTime.now
          flash[:notice] = I18n.t('errors.account_suspended_until', time: current_user.banned_until.strftime("%F %H:%M"), reason: current_user.banreason)
          current_user.disappear
          sign_out current_user
          redirect_to root_path
        else
          current_user.update_columns(banned: false, banned_until: nil, banreason: nil)
        end
      else
        flash[:notice] = I18n.t('errors.account_suspended_permanently', reason: current_user.banreason)
        current_user.disappear
        sign_out current_user
        redirect_to root_path
      end
    end
  end
  
  def check_maintenance
    sign_out current_user and redirect_to root_path unless $allow_login
  end
end
