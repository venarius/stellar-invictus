class GameController < ApplicationController
  def index
    get_local_users
    raise RedirectRequest.new(station_path) if current_user.docked?

    @ship_vars = current_user.active_spaceship&.get_attributes
  end

  def warp
    check_police
    check_warp_disrupt

    raise InvalidRequest if current_user.in_warp? || !(params[:id] || params[:uid])
    align_time = nil
    ship = current_user.active_spaceship

    if params[:id]
      location = Location.ensure(params[:id])
      raise InvalidRequest if location&.system_id != current_user.system_id
      align = ship.get_align_time

      # Fleet Warp
      if params[:fleet] && current_user.fleet
        fleet_members_in_system = current_user.fleet.users.where(system: current_user.system)
        align = fleet_members_in_system.map { |p| p.active_spaceship&.get_align_time }.compact.max

        fleet_members_in_system.each do |user|
          if !user.in_warp?
            WarpWorker.perform_async(user.id, location.id, 0, 0, false, align)
            align_time = (user.active_spaceship.warp_target_id == location.id) ? 0 : align
            user.broadcast(:fleet_warp, location: location.id, align_time: align_time) if user != current_user
          end
        end
      else
        WarpWorker.perform_async(current_user.id, location.id)
      end
      align_time = (ship.warp_target_id == location.id) ? 0 : align

    elsif params[:uid]
      user = User.ensure(params[:uid])
      raise InvalidRequest unless user
      raise InvalidRequest unless user.in_same_fleet_as(current_user)

      # Check location
      raise InvalidRequest.new('errors.user_must_be_in_same_system') unless user.system == current_user.system
      raise InvalidRequest.new('errors.already_at_location') if user.location == current_user.location

      WarpWorker.perform_async(current_user.id, user.location.id)
      align_time = (ship.warp_target_id == user.location.id) ? 0 : ship.get_align_time
    end

    render json: { align_time: align_time }, status: :ok
  end

  def jump
    check_police
    check_warp_disrupt
    raise InvalidRequest if current_user.in_warp? || !(current_user.location.jumpgate || current_user.location.wormhole?)

    JumpWorker.perform_async(current_user.id)

    render json: {}, status: :ok
  end

  def local_players
    get_local_users
    render partial: 'players', locals: { local_users: @local_users }
  end

  def ship_info
    render partial: 'ship_info', locals: { ship_vars: current_user.active_spaceship&.get_attributes }
  end

  def player_info
    render partial: 'player_info'
  end

  def assets
    var1 = Item.where(user: current_user, spaceship: nil, structure: nil).select(:location_id).distinct.pluck(:location_id)
    var2 = Spaceship.where(user: current_user).select(:location_id).distinct.pluck(:location_id)
    @locations = (var1 + var2).uniq
  end

  def chat
    cur_system = current_user.system
    @system_users = User.is_online.where(system: cur_system)
    @local_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.local.where(system: cur_system).first).last(10)
    @global_messages = ChatMessage.includes(:user).where(chat_room: ChatRoom.global).last(10)

    if params[:popup]
      render partial: 'game/chat_popup', locals: { local_messages: @local_messages, system_users: @system_users, global_messages: @global_messages }
    else
      render partial: 'game/chat', locals: { local_messages: @local_messages, system_users: @system_users, global_messages: @global_messages }
    end
  end

  def system_card
    render partial: 'game/system_card' unless current_user.docked?
  end

  def locations_card
    render partial: 'game/locations' unless current_user.docked?
  end

  private

  def get_local_users
    @local_users ||= User.includes(:faction).is_online.where(location: current_user.location, in_warp: false, docked: false)
  end

  def check_police
    raise InvalidRequest.new('errors.police_inbound') if Npc.police.targeting_user(current_user).exists?
  end

  def check_warp_disrupt
    raise InvalidRequest.new('errors.warp_disrupted') if current_user.active_spaceship&.is_warp_disrupted?
  end
end
