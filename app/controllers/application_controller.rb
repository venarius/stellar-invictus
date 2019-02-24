class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_no_faction
  before_action :update_last_action
  before_action :check_banned
  before_action :set_chat
  
  include ApplicationHelper
  
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :family_name, :avatar, :email, :password, :password_confirmation, :provider, :uid])
  end
  
  def after_sign_in_path_for(resource)
    current_user.faction ? game_path : factions_path
  end
  
  def redirect_if_no_faction
    if current_user
      redirect_to factions_path unless current_user.faction
    end
  end
  
  def call_police(player)
    if Npc.where(npc_type: 'police', target: player.id).empty?
      if player.system.high?
        PoliceWorker.perform_async(player.id, 2)
      elsif player.system.medium?
        PoliceWorker.perform_async(player.id, 10)
      end
    end
  end
  
  def update_last_action
    if current_user
      current_user.update_columns(last_action: DateTime.now) if (current_user&.last_action and current_user&.last_action < 5.minutes.ago) || current_user&.last_action == nil
    end
  end
  
  def check_docked
    render json: {}, status: 400 and return unless current_user.docked
  end
  
  def check_admin
    redirect_back(fallback_location: root_path) unless current_user.admin
  end
  
  def check_chat_mod
    redirect_back(fallback_location: root_path) unless current_user.chat_mod || current_user.admin
  end
  
  def check_banned
    if current_user.present? and current_user.banned
      if current_user.banned_until
        if current_user.banned_until > DateTime.now
          flash[:notice] = I18n.t('errors.account_suspended_until', time: current_user.banned_until.strftime("%F %H:%M"), reason: current_user.banreason)
          sign_out current_user and redirect_to root_path
        else
          current_user.update_columns(banned: false, banned_until: nil, banreason: nil)
        end
      else
        flash[:notice] = I18n.t('errors.account_suspended_permanently', reason: current_user.banreason)
        sign_out current_user and redirect_to root_path
      end
    end
  end
  
  def set_chat
    if current_user and current_user.system
      current_user.system.wormhole? ? @system_users = [] : @system_users = User.where("online > 0").where(system: current_user.system)
      @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.where(chatroom_type: :global).first).last(20)
    end
  end
  
  def find_user
    @user = User.find(params[:id]) rescue nil if params[:id]
    render json: {}, status: 400 and return unless @user
  end
  
end
