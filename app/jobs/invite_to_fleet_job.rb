class InviteToFleetJob < ApplicationJob
  queue_as :default

  def perform(user, target, fleet)
    user = User.ensure(user)
    fleet = Fleet.ensure(fleet)
    target = User.ensure(target)

    target.broadcast(:invited_to_fleet, data: render_message(user, fleet))
  end

  private

  def render_message(user, fleet)
    ApplicationController.renderer.render(
      partial: 'chat_messages/invited_to_fleet',
      locals: { user: user, fleet: fleet }
    )
  end
end
