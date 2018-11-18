class FriendsController < ApplicationController
  def index
    @friends = current_user.friendships.where(accepted: true)
    @pending = Friendship.where('friend_id = ? OR user_id = ?', current_user.id, current_user.id).where(accepted: false)
  end
  
  def add_friend
    if params[:id]
      friend = User.find(params[:id]) rescue nil
      if friend and friend != current_user and current_user.friends.where(id: friend.id).empty?
        friendship = Friendship.find_by(user: friend, friend: current_user, accepted: false) rescue nil
        if friendship
          if accept_friendship(friendship.id)
            render json: {}, status: 200 and return
          end
        else
          Friendship.create(user: current_user, friend: friend, accepted: false)
          # Tell user
          ActionCable.server.broadcast("player_#{friend.id}", method: 'new_friendrequest')
          render json: {}, status: 200 and return
        end
      end
    end
    render json: {}, status: 400
  end
  
  def accept_request
    if params[:id]
      if accept_friendship(params[:id])
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  def remove_friend
    if params[:id]
      friend = User.find(params[:id]) rescue nil
      if friend
        find = current_user.friends.find(friend.id) rescue nil
        if find
          current_user.friends.destroy(friend)
        else
          friendship = Friendship.find_by(user: friend, friend: current_user)
          friendship.destroy if friendship
        end
        render json: {}, status: 200 and return
      end
    end
    render json: {}, status: 400
  end
  
  private
  
  def accept_friendship(id)
    friendship = Friendship.find(id) rescue nil
    if friendship and friendship.user != current_user and friendship.friend == current_user and !friendship.accepted
      friendship.update_attributes(accepted: true)
      Friendship.create(user: current_user, friend: friendship.user, accepted: true)
      return true
    end
    false
  end
end