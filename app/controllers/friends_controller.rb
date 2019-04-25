class FriendsController < ApplicationController
  def index
    @friends = current_user.friendships.where(accepted: true)
    @pending = Friendship.where('friend_id = ? OR user_id = ?', current_user.id, current_user.id).where(accepted: false)
  end

  def add_friend
    friend = User.ensure(params[:id])
    raise InvalidRequest if !friend || (friend == current_user) || current_user.friendships.where(friend: friend).exists?

    if (request = friend.friendships.is_request.where(friend: current_user).first)
      raise InvalidRequest if !accept_friendship(request)
    else
      # Create Request
      Friendship.create(user: current_user, friend: friend, accepted: false)
      friend.broadcast(:notify_info,
        text: I18n.t('notification.received_friend_request', user: current_user.full_name)
      )
    end

    render json: {}, status: :ok
  end

  def accept_request
    raise InvalidRequest unless accept_friendship(params[:id])
    render json: {}, status: :ok
  end

  def remove_friend
    friend = User.ensure(params[:id])
    raise InvalidRequest unless friend

    if (found_friend = current_user.friends.where(id: friend.id))
      current_user.friends.destroy(found_friend)
    else
      Friendship.where(user: friend, friend: current_user).first&.destroy
    end
    render json: {}, status: :ok
  end

  def search
    raise InvalidRequest unless params[:name]
    result = User.where('full_name ILIKE ?', "%#{params[:name]}%").where.not(faction_id: nil).first(20)
    render partial: 'friends/search', locals: { users: result }
  end

  private

  def accept_friendship(friendship)
    friendship = Friendship.ensure(friendship)
    return false if !friendship || friendship.user == current_user || friendship.friend != current_user || friendship.accepted?

    friendship.update(accepted: true)
    # make the reverse friendship record
    Friendship.create(user: friendship.friend, friend: friendship.user, accepted: true)
  end
end
