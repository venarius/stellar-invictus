class FleetsController < ApplicationController
  def invite
    if params[:id]
      user = User.find(params[:id]) rescue nil
      if user
        if current_user.fleet.nil?
          room = ChatRoom.create(title: 'Fleet', chatroom_type: 'custom')
          room.users << current_user
          fleet = Fleet.create(creator: current_user, chat_room: room)
          current_user.update_columns(fleet_id: fleet.id)
        end
        InviteToFleetJob.perform_now(current_user.id, user.id, fleet.id)
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def accept_invite
    if params[:id]
      fleet = Fleet.find(params[:id]) rescue nil
      if fleet
        room = fleet.chat_room
        room.users << current_user
        current_user.update_columns(fleet_id: fleet.id)
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: current_user.full_name)}</td></tr>")
        ChatChannel.broadcast_to(room, method: 'update_players', names: room.users.where("online > 0").map(&:full_name))
        ChatChannel.broadcast_to(room, method: 'player_appeared')
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
end