class LocalChannel < ApplicationCable::Channel
  def subscribed
    stream_from "location_#{current_user.location_id}"
  end
  
  def reload
    stop_all_streams
    stream_from "location_#{current_user.reload.location_id}"
  end
end