class AppearWorker < ApplicationWorker
  # This Worker will be run when the user logs in
  def perform(user_id)
    User::Appear.(user: user_id)
  end
end
