class AdminController < ApplicationController
  before_action :check_admin, except: [:mute, :unmute, :delete_chat]
  before_action :check_chat_mod, only: [:mute, :unmute, :delete_chat]

  def index
  end

  def search
    raise InvalidRequest unless params[:name]
    result = User.where('full_name ILIKE ?', "%#{params[:name]}%").where.not(faction_id: nil).first(20)
    render partial: 'admin/search', locals: { users: result }, status: :ok
  end

  def teleport
    raise InvalidRequest if current_user.in_warp?
    current_user.teleport(user)
    render json: {}, status: :ok
  end

  def set_credits
    user.update(units: params[:credits])
    user.broadcast(:refresh_player_info)
    render json: { message: I18n.t('admin.successfully_set_credits') }, status: :ok
  end

  def ban
    raise InvalidRequest if !params[:duration] || !params[:reason]
    user.ban(params[:duration], params[:reason])
    render json: {
      message: I18n.t('admin.successfully_banned_user'),
      banned_until: (user.banned_until&.strftime('%F %H:%M'))
    }, status: :ok
  end

  def unban
    user.unban
    render json: { message: I18n.t('admin.successfully_unbanned_user') }, status: :ok
  end

  def server_message
    raise InvalidRequest unless params[:text]
    ActionCable.server.broadcast('appearance', method: 'server_message', text: params[:text])
    render json: {}, status: :ok # could do (head :ok)
  end

  def mute

    user.update(muted: true)
    render json: { message: I18n.t('admin.successfully_muted_user') }, status: :ok
  end

  def unmute
    user.update(muted: false)
    render json: { message: I18n.t('admin.successfully_unmuted_user') }, status: :ok
  end

  def delete_chat
    user.chat_messages.destroy_all
    render json: { message: I18n.t('admin.successfully_deleted_chat') }, status: :ok
  end

  private

  def check_chat_mod
    redirect_back(fallback_location: root_path) if !current_user.chat_mod? && !current_user.admin?
  end

  def check_admin
    redirect_back(fallback_location: root_path) unless current_user.admin?
  end

  def user
    @user ||= begin
      user = User.ensure(params[:id])
      raise InvalidRequest unless user
      user
    end
  end

end
