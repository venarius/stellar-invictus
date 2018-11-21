class FleetsController < ApplicationController
  # Invite user to fleet
  def invite
    if params[:id]
      user = User.find(params[:id]) rescue nil
      
      # If user and user is not in fleet
      if user and user.fleet.nil?
        
        # If current user is not in fleet
        if current_user.fleet.nil?
          # Create new room and new fleet
          room = ChatRoom.create(title: 'Fleet', chatroom_type: 'custom')
          room.users << current_user
          fleet = Fleet.create(creator: current_user, chat_room: room)
          current_user.update_columns(fleet_id: fleet.id)
        # If current user is in fleet
        else
          # Only get some variables
          fleet = current_user.fleet
          room = current_user.fleet.chat_room
        end
        
        # Invite to Fleet Worker
        InviteToFleetJob.perform_now(current_user.id, user.id, fleet.id)
        
        # Render 200 OK
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Accept invitation of another user
  def accept_invite
    if params[:id] and current_user.fleet.nil?
      fleet = Fleet.find(params[:id]) rescue nil
      
      # If fleet
      if fleet
        # Get Room
        room = fleet.chat_room
        
        # Add current user to room users
        room.users << current_user
        
        # Set fleet_id of current_user
        current_user.update_columns(fleet_id: fleet.id)
        
        # Broadcast
        broadcast("join", current_user, room)
        
        # Render 200 OK
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Remove user from fleet
  def remove
    if params[:id] and current_user.fleet and current_user.fleet.creator == current_user
      user = User.find(params[:id]) rescue nil
      
      # If user and user is in current users fleet and user is not current user
      if user and user.fleet == current_user.fleet and user != current_user
        
        # Get Room of current user
        room = current_user.fleet.chat_room
        
        # Remove user from room
        room.users.destroy(user)
        
        # Broadcast
        broadcast("leave", user, room)
        
        # Remove fleet id of user
        user.update_columns(fleet_id: nil)
        
        # Render 200 OK
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  private
  
  def broadcast(type, user, room)
    if type == "join"
      ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: user.full_name)}</td></tr>")
    else
      ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: user.full_name)}</td></tr>")
      ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
    end
    ChatChannel.broadcast_to(room, method: 'update_players', names: map_and_sort(room.users.where("online > 0")))
    ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
  end
  
end