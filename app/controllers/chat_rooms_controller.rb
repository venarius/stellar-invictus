class ChatRoomsController < ApplicationController
  def create
    raise InvalidRequest if params[:title].blank?

    room = ChatRoom.new(title: params[:title], chatroom_type: :custom)
    if room.save
      room.users << current_user
      render json: { 'id': room.identifier }, status: :ok
    else
      render json: { error_message: room.errors.full_messages }, status: :bad_request
    end
  end

  # Join a ChatRoom
  def join
    room = ChatRoom.ensure(params[:id])
    raise InvalidRequest unless room
    raise InvalidRequest.new('errors.couldnt_find_chat_room') unless room.custom?
    raise InvalidRequest.new('errors.already_joined_chat_room') if room.user_in_room?(current_user)

    if room.fleet
      ChatChannel.broadcast_to(room, method: 'player_appeared')
      current_user.update(fleet_id: room.fleet.id)
    end

    room.users << current_user

    ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: current_user.full_name)}</td></tr>")
    room.update_local_players

    render json: { 'id': room.identifier }, status: :ok
  end

  # Leave a ChatRoom
  def leave
    room = ChatRoom.ensure(params[:id])
    raise InvalidRequest if !room || !room.user_in_room?(current_user)

    room.users.destroy(current_user)

    ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: current_user.full_name)}</td></tr>")
    room.update_local_players

    if room.fleet
      ChatChannel.broadcast_to(room, method: :player_appeared)
      current_user.update(fleet: nil)

      # If User was creator of fleet, then Destroy
      if room.fleet.creator == current_user
        room.fleet.update(creator: nil)
        room.destroy
      end
    end

    if room.users.count.zero? && !%w[ROOKIES RECRUIT].include?(room.identifier)
      room.destroy
    end

    render(json: {}, status: :ok)
  end

  # Invite other user to conversation
  def start_conversation
    user = User.ensure(params[:id])
    raise InvalidRequest if !user || user == current_user

    if !params[:identifier]
      room = ChatRoom.create(title: I18n.t('chat.conversation'), chatroom_type: :custom)
      room.users << current_user
    else
      room = ChatRoom.ensure(params[:identifier])
    end

    InviteToConversationJob.perform_now(current_user.id, room.identifier, user.id)

    render json: { 'id': room.identifier }, status: :ok
  end

  def search
    raise InvalidRequest if !params[:name] || !params[:identifier]

    result = User.where('full_name ILIKE ?', "%#{params[:name]}%").where.not(faction_id: nil).first(20)

    render(partial: 'game/chat/search', locals: { users: result, identifier: params[:identifier] })
  end
end
