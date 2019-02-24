class AdminController < ApplicationController
  before_action :check_admin, except: [:mute, :unmute, :delete_chat]
  before_action :check_chat_mod, only: [:mute, :unmute, :delete_chat]
  before_action :find_user, only: [:teleport, :set_credits, :ban, :unban, :mute, :unmute, :delete_chat]
  
  def index
  end
  
  def search
    if params[:name]
      result = User.where("full_name ILIKE ?", "%#{params[:name]}%").where.not(faction_id: nil).first(20)
      render partial: 'admin/search', locals: {users: result} and return
    end
    render json: {}, status: 400
  end
  
  def teleport
    if !current_user.in_warp
      current_user.teleport(@user)
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def set_credits
    @user.update_columns(units: params[:credits].to_i)
    ActionCable.server.broadcast("player_#{@user.id}", method: 'refresh_player_info')
    render json: {message: I18n.t('admin.successfully_set_credits')}, status: 200 and return
  end
  
  def ban
    if params[:id] and params[:duration] and params[:reason]
      @user.ban(params[:duration], params[:reason])
      render json: {message: I18n.t('admin.successfully_banned_user'), banned_until: (user.banned_until.strftime("%F %H:%M") rescue 0)}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def unban
    @user.unban
    render json: {message: I18n.t('admin.successfully_unbanned_user')}, status: 200 and return
  end
  
  def server_message
    if params[:text]
      ActionCable.server.broadcast("appearance", method: 'server_message', text: params[:text])
      render json: {}, status: 200 and return
    end
    render json: {}, status: 400
  end
  
  def mute
    @user.update_columns(muted: true)
    render json: {message: I18n.t('admin.successfully_muted_user')}, status: 200 and return
  end
  
  def unmute
    @user.update_columns(muted: false)
    render json: {message: I18n.t('admin.successfully_unmuted_user')}, status: 200 and return
  end
  
  def delete_chat
    @user.chat_messages.destroy_all
    render json: {message: I18n.t('admin.successfully_deleted_chat')}, status: 200 and return
  end
  
end