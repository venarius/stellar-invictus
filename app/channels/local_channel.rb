class LocalChannel < ApplicationCable::Channel
  def subscribed
    stream_from "location_#{current_user.location.id}"
  end
  
  def reload
    stop_all_streams
    stream_from "location_#{current_user.reload.location.id}"
  end
end