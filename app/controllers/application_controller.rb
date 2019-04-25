class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_if_no_faction, :update_last_action, :check_banned, :set_chat

  include ApplicationHelper

  rescue_from InvalidRequest, with: :render_error_response
  rescue_from RedirectRequest, with: :handle_redirect_request

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
    raise InvalidRequest unless current_user.docked?
  end

  def check_banned
    if current_user&.banned?
      if current_user.banned_until
        if current_user.banned_until > DateTime.now
          flash[:notice] = I18n.t('errors.account_suspended_until', time: current_user.banned_until.strftime('%F %H:%M'), reason: current_user.banreason)
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

  def translate(text)
    if text
      temp_text = I18n.t(text)
      text = temp_text.start_with?('translation missing:') ? text : temp_text
    end
    text
  end

  def render_error_response(err)
    json = {}

    msg = err.message
    if msg.is_a?(String)
      msg = nil if msg == 'InvalidRequest'
      msg = translate(msg)
      json = { error_message: msg }
    else
      json = msg
    end
    # Uncomment to show backtrace of InvalidRequests
    # ap msg if msg.present?
    # root = Rails.root.to_s
    # ap err.backtrace.select { |e| e.index(root) }.reject{ |e| e.index("spec/support") }.map{ |e| e.gsub(root, "") }

    render json: json.compact, status: :bad_request
  end

  def handle_redirect_request(req)
    # ap "!! Redirecting to: #{req.route} error:\"#{req.error}\""
    if req.error.present?
      redirect_to req.route, flash: { error: translate(req.error) }
    else
      redirect_to req.route
    end
  end

end
