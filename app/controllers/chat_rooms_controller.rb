class ChatRoomsController < ApplicationController
  # Create a new ChatRoom
  def create
    if params[:title]
      room = ChatRoom.new(title: params[:title], chatroom_type: 'custom')
      if room.save
        room.users << current_user
        render json: {'id': room.identifier}, status: 200 and return
      else
        render json: {error_message: room.errors.full_messages}, status: 400 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Join a ChatRoom
  def join
    if params[:id]
      room = ChatRoom.find_by(identifier: params[:id]) rescue nil
      
      # Get users of room
      room_users = room.users rescue nil
      
      # If room found and room is custom type and player hasn't joined already
      if room and room.custom?
        
        # Check if already joined
        render json: {'error_message': I18n.t('errors.already_joined_chat_room')}, status: 400 and return unless room_users.where(id: current_user.id).empty?
        
        # If room has fleet -> Fleet Stuff
        if room.fleet
          ChatChannel.broadcast_to(room, method: 'player_appeared')
          current_user.update_columns(fleet_id: room.fleet.id)
        end
        
        # Add current_user to room users
        room_users << current_user
        
        # Broadcast
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_joined_channel', user: current_user.full_name)}</td></tr>")
        room.update_local_players
        
        # Render 200 OK
        render json: {'id': room.identifier}, status: 200 and return
      else
        render json: {'error_message': I18n.t('errors.couldnt_find_chat_room')}, status: 400 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Leave a ChatRoom
  def leave
    if params[:id]
      room = ChatRoom.find_by(identifier: params[:id]) rescue nil
      
      # Get users of room
      room_users = room.users rescue nil
      
      # If room and user is in room
      if room and room_users.where(id: current_user.id).present?
        
        # Remove user from the room
        room_users.destroy(current_user)
        
        # Broadcast
        ChatChannel.broadcast_to(room, message: "<tr><td>#{I18n.t('chat.user_left_channel', user: current_user.full_name)}</td></tr>")
        room.update_local_players
        
        # If the room has a fleet
        if room.fleet
          # Fleet Stuff
          ChatChannel.broadcast_to(room, method: 'player_appeared')
          current_user.update_columns(fleet_id: nil)
          
          # If User was creator of fleet
          if room.fleet.creator == current_user
            # Destroy fleet
            room.fleet.update_columns(user_id: nil)
            room.destroy
          end
        end
        
        # If room is empty -> destroy
        if room_users.count <= 0 and room.identifier != 'ROOKIES'
          room.destroy
        end
        
        # Render 200 OK
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  # Invite other user to conversation
  def start_conversation
    if params[:id]
      user = User.find(params[:id])
      
      # If user and user is not current_user
      if user and user != current_user
        
        if !params[:identifier]
          # Create a new ChatRoom
          room = ChatRoom.create(title: I18n.t('chat.conversation'), chatroom_type: 'custom')
          
          # Add User to ChatRoom
          room.users << current_user
        else
          room = ChatRoom.find_by(identifier: params[:identifier])
        end
        
        # Perform Job
        InviteToConversationJob.perform_now(current_user.id, room.identifier, user.id)
        
        # Render 200 OK
        render json: {'id': room.identifier}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def search
    if params[:name] and params[:identifier]
      result = User.where("full_name LIKE ?", "%#{params[:name]}%").first(20)
      render partial: 'game/chat/search', locals: {users: result, identifier: params[:identifier]} and return
    end
    render json: {}, status: 400
  end
end