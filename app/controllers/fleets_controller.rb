class FleetsController < ApplicationController

  def invite
    user = User.ensure(params[:id])
    raise InvalidRequest if !user || user.fleet

    # If current user is not in fleet
    if current_user.fleet.nil?
      # Create new room and new fleet
      room = ChatRoom.create(title: 'Fleet', chatroom_type: :custom)
      room.users << current_user
      fleet = Fleet.create(creator: current_user, chat_room: room)
      current_user.update(fleet_id: fleet.id)
    # If current user is in fleet
    else
      # Only get some variables
      fleet = current_user.fleet
      room = current_user.fleet.chat_room
    end

    # Invite to Fleet Worker
    InviteToFleetJob.perform_now(current_user.id, user.id, fleet.id)

    render json: { 'id': room.identifier }, status: :ok
  end

  def accept_invite
    fleet = Fleet.ensure(params[:id])
    raise InvalidRequest if !fleet || current_user.fleet

    room = fleet.chat_room
    room.users << current_user
    current_user.update(fleet: fleet)
    broadcast(:join, current_user, room)

    render json: { 'id': room.identifier }, status: :ok
  end

  def remove
    user = User.ensure(params[:id])
    raise InvalidRequest if !user || (user == current_user) || (user.fleet != current_user.fleet) || !current_user.fleet || (current_user.fleet.creator != current_user)

    room = current_user.fleet.chat_room
    room.users.delete(user)
    broadcast(:leave, user, room)
    user.update(fleet_id: nil)

    render json: {}, status: :ok
  end

  private

  def broadcast(type, user, room)
    if type == :join
      ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: user.full_name)}</td></tr>")
    else
      ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: user.full_name)}</td></tr>")
      user.broadcast(:reload_fleet)
    end
    room.update_local_players
    user.location.broadcast(:player_appeared)
  end

end
