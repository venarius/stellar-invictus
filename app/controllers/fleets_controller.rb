class FleetsController < ApplicationController
  def invite
    if params[:id]
      user = User.find(params[:id]) rescue nil
      if user and user.fleet.nil?
        if current_user.fleet.nil?
          room = ChatRoom.create(title: 'Fleet', chatroom_type: 'custom')
          room.users << current_user
          fleet = Fleet.create(creator: current_user, chat_room: room)
          current_user.update_columns(fleet_id: fleet.id)
        else
          fleet = current_user.fleet
          room = current_user.fleet.chat_room
        end
        InviteToFleetJob.perform_now(current_user.id, user.id, fleet.id)
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def accept_invite
    if params[:id] and current_user.fleet.nil?
      fleet = Fleet.find(params[:id]) rescue nil
      if fleet
        room = fleet.chat_room
        room.users << current_user
        current_user.update_columns(fleet_id: fleet.id)
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: current_user.full_name)}</td></tr>")
        ChatChannel.broadcast_to(room, method: 'update_players', names: map_and_sort(room.users.where("online > 0")))
        ActionCable.server.broadcast("location_#{current_user.location.id}", method: 'player_appeared')
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def remove
    if params[:id] and current_user.fleet and current_user.fleet.creator == current_user
      user = User.find(params[:id]) rescue nil
      if user and user.fleet == current_user.fleet and user != current_user
        room = current_user.fleet.chat_room
        room.users.destroy(user)
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: user.full_name)}</td></tr>")
        ChatChannel.broadcast_to(room, method: 'update_players', names: map_and_sort(room.users.where("online > 0")))
        ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
        ActionCable.server.broadcast("player_#{user.id}", method: 'reload_page')
        user.update_columns(fleet_id: nil)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
end