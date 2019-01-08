class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "appearance"
    current_user.appear
  end
 
  def unsubscribed
    current_user.disappear
  end
end