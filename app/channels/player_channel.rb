class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_#{current_user.id}"
  end
end