class GameController < ApplicationController
  before_action :get_local_users, only: [:index, :local_players]
  before_action :check_police, only: [:warp, :jump]
  before_action :check_warp_disrupt, only: [:warp, :jump]

  def index
    if current_user.docked
      redirect_to(station_path) && (return)
    end
    @ship_vars = current_user.active_spaceship&.get_attributes
  end

  def warp
    if (params[:id] || params[:uid]) && !current_user.in_warp

      if params[:id]
        location = Location.find(params[:id]) rescue nil
        if location && (location.system_id == current_user.system_id)

          # Fleet Warp
          if params[:fleet] && current_user.fleet
            align = current_user.fleet.users.where(system: current_user.system).map { |p| p.active_spaceship&.get_align_time }.sort.reverse.first
            current_user.fleet.users.where(system: current_user.system).each do |user|
              unless user.in_warp
                WarpWorker.perform_async(user.id, location.id, 0, 0, false, align)
                if user.active_spaceship.warp_target_id == location.id
                  ActionCable.server.broadcast("player_#{user.id}", method: 'fleet_warp', location: location.id, align_time: 0) if user != current_user
                else
                  ActionCable.server.broadcast("player_#{user.id}", method: 'fleet_warp', location: location.id, align_time: align) if user != current_user
                end
              end
            end
          else
            WarpWorker.perform_async(current_user.id, location.id)
          end

          if current_user.active_spaceship&.warp_target_id == location.id
            render json: { align_time: 0 }, status: 200
          else
            render json: { align_time: align ? align : current_user.active_spaceship&.get_align_time }, status: 200
          end
        else
          render json: {}, status: 400
        end
      elsif params[:uid]
        user = User.find(params[:uid]) rescue nil
        if user && user.in_same_fleet_as(current_user)
          # Check location
          render(json: { "error_message": I18n.t('errors.user_must_be_in_same_system') }, status: 400) && (return) unless user.system == current_user.system
          render(json: { "error_message": I18n.t('errors.already_at_location') }, status: 400) && (return) if user.location == current_user.location

          WarpWorker.perform_async(current_user.id, user.location.id)

          if current_user.active_spaceship&.warp_target_id == user.location.id
            render json: { align_time: 0 }, status: 200
          else
            render json: { align_time: current_user.active_spaceship&.get_align_time }, status: 200
          end
        else
          render json: {}, status: 400
        end
      end
    else
      render json: {}, status: 400
    end
  end

  def jump
    if !current_user.in_warp && (current_user.location.jumpgate || current_user.location.wormhole?)
      JumpWorker.perform_async(current_user.id)
      render json: {}, status: 200
    else
      render json: {}, status: 400
    end
  end

  def local_players
    render partial: 'players', locals: { local_users: @local_users }
  end

  def ship_info
    render partial: 'ship_info', locals: { ship_vars: current_user.active_spaceship&.get_attributes }
  end

  def player_info
    render partial: 'player_info'
  end

  def assets
    var1 = Item.where(user: current_user, spaceship: nil, structure: nil).pluck(:location_id)
    var2 = Spaceship.where(user: current_user).pluck(:location_id)
    @locations = (var1 + var2).uniq.compact
  end

  def chat
    @system_users = User.where("online > 0").where(system: current_user.system)
    @local_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.find_by(system: current_user.system)).last(10)
    @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.where(chatroom_type: :global).first).last(10)

    if params[:popup]
      render partial: 'game/chat_popup', locals: { local_messages: @local_messages, system_users: @system_users, global_messages: @global_messages }
    else
      render partial: 'game/chat', locals: { local_messages: @local_messages, system_users: @system_users, global_messages: @global_messages }
    end
  end

  def system_card
    render partial: 'game/system_card' unless current_user.docked
  end

  def locations_card
    render partial: 'game/locations' unless current_user.docked
  end

  private

  def get_local_users
    @local_users = User.includes(:faction).where(location: current_user.location, in_warp: false, docked: false).where("online > 0")
  end

  def check_police
    if Npc.police.targeting_user(current_user).exists?
      render(json: { 'error_message' => I18n.t('errors.police_inbound') }, status: 400) && (return)
    end
  end

  def check_warp_disrupt
    if current_user.active_spaceship&.is_warp_disrupted
      render(json: { 'error_message' => I18n.t('errors.warp_disrupted') }, status: 400) && (return)
    end
  end
end
