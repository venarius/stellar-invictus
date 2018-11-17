class FriendsController < ApplicationController
  def index
    @friends = Friendship.where("user_id = ? OR friend_id = ?", current_user.id, current_user.id).where(accepted: true)
    @pending = Friendship.where("user_id = ? OR friend_id = ?", current_user.id, current_user.id).where(accepted: false)
  end
  
  def add_friend
    if params[:id] and (Friendship.where("(user_id = ? OR friend_id = ?) OR (user_id = ? OR friend_id = ?)", params[:id], current_user.id, current_user.id, params[:id]).empty?)
      user = User.find(params[:id])
      unless user == current_user
        Friendship.create(user: current_user, friend: user, accepted: false)
        # Tell user
        ActionCable.server.broadcast("player_#{user.id}", method: 'new_friendrequest')
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def accept_request
    if params[:id]
      friendship = Friendship.find(params[:id]) rescue nil
      if friendship and friendship.friend == current_user and !friendship.accepted
        friendship.update_columns(accepted: true)
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def remove_friend
    if params[:id]
      friendship = Friendship.where("(user_id = ? OR friend_id = ?) OR (user_id = ? OR friend_id = ?)", params[:id], current_user.id, current_user.id, params[:id]).first rescue nil
      if friendship and (friendship.friend == current_user or friendship.user == current_user)
        friendship.destroy
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
end