class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'appearance'
    User::Appear.(user: current_user)
  end

  def unsubscribed
    User::Disappear.(user: current_user)
  end
end
