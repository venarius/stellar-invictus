class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end
 
  def unsubscribed
    current_user.disappear
  end
end