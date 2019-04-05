class FleetsController < ApplicationController
  # Invite user to fleet
  def invite
    if params[:id]
      user = User.ensure(params[:id])

      # If user and user is not in fleet
      if user && user.fleet.nil?

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

        # Render 200 OK
        render(json: { 'id': room.identifier }, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  # Accept invitation of another user
  def accept_invite
    if params[:id] && current_user.fleet.nil?
      fleet = Fleet.ensure(params[:id])

      # If fleet
      if fleet
        # Get Room
        room = fleet.chat_room

        # Add current user to room users
        room.users << current_user

        # Set fleet_id of current_user
        current_user.update(fleet_id: fleet.id)

        # Broadcast
        broadcast("join", current_user, room)

        # Render 200 OK
        render(json: { 'id': room.identifier }, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  # Remove user from fleet
  def remove
    if params[:id] && current_user.fleet && (current_user.fleet.creator == current_user)
      user = User.ensure(params[:id])

      # If user and user is in current users fleet and user is not current user
      if user && (user.fleet == current_user.fleet) && (user != current_user)

        # Get Room of current user
        room = current_user.fleet.chat_room

        # Remove user from room
        room.users.delete(user)

        # Broadcast
        broadcast("leave", user, room)

        # Remove fleet id of user
        user.update(fleet_id: nil)

        # Render 200 OK
        render(json: {}, status: :ok) && (return)
      end
    end
    render json: {}, status: :bad_request
  end

  private

  def broadcast(type, user, room)
    if type == "join"
      ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: user.full_name)}</td></tr>")
    else
      ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: user.full_name)}</td></tr>")
      user.broadcast(:reload_fleet)
    end
    room.update_local_players
    user.location.broadcast(:player_appeared)
  end

end
