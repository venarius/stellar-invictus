class ChatRoomsController < ApplicationController
  def create
    if params[:title]
      room = ChatRoom.new(title: params[:title], chatroom_type: 'custom')
      if room.save
        room.users << current_user
        render json: {'id': room.identifier}, status: 200 and return
      else
        render json: {}, status: 400 and return
      end
    end
    render json: {}, status: 400
  end
  
  def join
    if params[:id]
      room = ChatRoom.find_by(identifier: params[:id]) rescue nil
      if room and room.custom? and room.users.where(id: current_user.id).empty?
        unless room.fleet.nil?
          ChatChannel.broadcast_to(room, method: 'player_appeared')
          current_user.update_columns(fleet_id: room.fleet.id)
        end
        room.users << current_user
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: current_user.full_name)}</td></tr>")
        ChatChannel.broadcast_to(room, method: 'update_players', names: room.users.where("online > 0").map(&:full_name))
        render json: {'id': room.identifier}, status: 200 and return
      else
        render json: {'error_message': I18n.t('errors.couldnt_find_chat_room')}, status: 400 and return
      end
    end
    render json: {}, status: 400
  end
  
  def leave
    if params[:id]
      room = ChatRoom.find_by(identifier: params[:id]) rescue nil
      if room and room.users.where(id: current_user.id).present?
        room.users.destroy(current_user)
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: current_user.full_name)}</td></tr>")
        ChatChannel.broadcast_to(room, method: 'update_players', names: room.users.where("online > 0").map(&:full_name))
        if room.fleet
          ChatChannel.broadcast_to(room, method: 'player_appeared')
          current_user.update_columns(fleet_id: nil)
        end
        if room.users.count <= 0
          room.destroy
        end
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def start_conversation
    if params[:id]
      user = User.find(params[:id])
      if user and user != current_user
        room = ChatRoom.create(title: I18n.t('chat.conversation'), chatroom_type: 'custom')
        room.users << current_user
        InviteToConversationJob.perform_now(current_user.id, room.identifier, user.id)
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
end