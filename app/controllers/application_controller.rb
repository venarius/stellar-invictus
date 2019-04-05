class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_no_faction
  before_action :update_last_action
  before_action :check_banned
  before_action :set_chat

  include ApplicationHelper

  rescue_from InvalidRequest, with: :render_error_response

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
    return if Npc.police.targeting_user(player).exists?

    if player.system.high?
      PoliceWorker.perform_async(player.id, 2)
    elsif player.system.medium?
      PoliceWorker.perform_async(player.id, 10)
    end
  end

  def update_last_action
    if current_user
      current_user.update(last_action: DateTime.now) if (current_user&.last_action && (current_user&.last_action < 5.minutes.ago)) || current_user&.last_action == nil
    end
  end

  def check_docked
    raise InvalidRequest unless current_user.docked
  end

  def check_banned
    if current_user&.banned?
      if current_user.banned_until
        if current_user.banned_until > DateTime.now
          flash[:notice] = I18n.t('errors.account_suspended_until', time: current_user.banned_until.strftime("%F %H:%M"), reason: current_user.banreason)
          sign_out(current_user) && redirect_to(root_path)
        else
          current_user.update(banned: false, banned_until: nil, banreason: nil)
        end
      else
        flash[:notice] = I18n.t('errors.account_suspended_permanently', reason: current_user.banreason)
        sign_out(current_user)
        redirect_to(root_path)
      end
    end
  end

  def set_chat
    if current_user&.system
      @system_users = []
      @system_users = current_user.system.users.is_online unless current_user.system.wormhole?
      @global_messages = ChatRoom.global.chat_messages.includes(:user).last(20)
    end
  end

  def render_error_response(err)
    msg = err.message
    msg = nil if msg == "InvalidRequest"
    if msg
      temp_msg = I18n.t(msg)
      msg = temp_msg.start_with?("translation missing:") ? msg : temp_msg
    end

    # Uncomment to show backtrace of InvalidRequests
    # ap msg if msg.present?
    # root = Rails.root.to_s
    # ap err
    #   .backtrace
    #   .select { |e| e.index(root) }
    #   .reject { |e| e.index("spec/support") }
    #   .map { |e| e.gsub(root, "") }

    render json: { error_message: msg }.compact, status: :bad_request
  end

end
