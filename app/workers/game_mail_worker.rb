class GameMailWorker < ApplicationWorker
  # This Worker will be run to tell another user that they got mail
  def perform(recipient)
    recipient = User.ensure(recipient)
    recipient&.broadcast(:received_mail)
  end
end
