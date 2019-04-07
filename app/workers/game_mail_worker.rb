class GameMailWorker < ApplicationWorker
  # This Worker will be run to tell another user that they got mail
  def perform(recipient_id)
    User.ensure(recipient_id)&.broadcast(:received_mail)
  end
end
