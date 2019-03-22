class FriendsController < ApplicationController
  def index
    @friends = current_user.friendships.where(accepted: true)
    @pending = Friendship.where('friend_id = ? OR user_id = ?', current_user.id, current_user.id).where(accepted: false)
  end

  def add_friend
    if params[:id]
      friend = User.find(params[:id]) rescue nil
      if friend && (friend != current_user) && current_user.friends.where(id: friend.id).empty?
        friendship = Friendship.find_by(user: friend, friend: current_user, accepted: false) rescue nil
        if friendship
          if accept_friendship(friendship.id)
            render(json: {}, status: 200) && (return)
          end
        else
          Friendship.create(user: current_user, friend: friend, accepted: false)
          # Tell user
          ActionCable.server.broadcast("player_#{friend.id}", method: 'notify_info', text: I18n.t('notification.received_friend_request', user: current_user.full_name))
          render(json: {}, status: 200) && (return)
        end
      end
    end
    render json: {}, status: 400
  end

  def accept_request
    if params[:id]
      if accept_friendship(params[:id])
        render(json: {}, status: 200) && (return)
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
        render(json: {}, status: 200) && (return)
      end
    end
    render json: {}, status: 400
  end

  def search
    if params[:name]
      result = User.where("full_name ILIKE ?", "%#{params[:name]}%").where.not(faction_id: nil).first(20)
      render(partial: 'friends/search', locals: { users: result }) && (return)
    end
    render json: {}, status: 400
  end

  private

  def accept_friendship(id)
    friendship = Friendship.find(id) rescue nil
    if friendship && (friendship.user != current_user) && (friendship.friend == current_user) && !friendship.accepted
      friendship.update_attributes(accepted: true)
      Friendship.create(user: current_user, friend: friendship.user, accepted: true)
      return true
    end
    false
  end
end
