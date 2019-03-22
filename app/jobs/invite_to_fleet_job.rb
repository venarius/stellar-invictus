class InviteToFleetJob < ApplicationJob
  queue_as :default

  def perform(user_id, target_id, fleet_id)
    user = User.find(user_id)
    fleet = Fleet.find(fleet_id)

    ActionCable.server.broadcast("player_#{target_id}", method: 'invited_to_fleet', data: render_message(user, fleet))
  end

  private
  def render_message(user, fleet)
    ApplicationController.renderer.render(partial: 'chat_messages/invited_to_fleet', locals: { user: user, fleet: fleet })
  end
end
