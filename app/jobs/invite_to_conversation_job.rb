class InviteToConversationJob < ApplicationJob
  queue_as :default

  def perform(user_id, room_id, target_id)
    user = User.ensure(user_id)
    room = ChatRoom.ensure(room_id)
    target = User.ensure(target_id)

    target.broadcast(:invited_to_conversation, data: render_message(user, room))
  end

  private

  def render_message(user, room)
    ApplicationController.renderer.render(
      partial: 'chat_messages/invited_to_conversation',
      locals: { user: user, room: room }
    )
  end
end
